#!/bin/sh
# Purpose: add an issue to the repository Project and perform guarded Status transitions.

set -eu

repo_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$repo_root"

issue_number=${1:-}
requested_status=${2:-}
approval_flag=${3:-}

usage() {
  echo "Usage: $0 <issue-number> <inbox|refinement|ready|in-progress|review|done> [--approve-ready]" >&2
  exit 2
}

if ! printf '%s' "$issue_number" | grep -Eq '^[0-9]+$'; then
  usage
fi

case "$requested_status" in
  inbox) status_name="Inbox" ;;
  refinement) status_name="Refinement" ;;
  ready) status_name="Ready" ;;
  in-progress) status_name="In Progress" ;;
  review) status_name="Review" ;;
  done) status_name="Done" ;;
  *) usage ;;
esac

if [ -n "$approval_flag" ] && { [ "$requested_status" != "ready" ] || [ "$approval_flag" != "--approve-ready" ]; }; then
  usage
fi

if [ "$requested_status" = "ready" ] && [ "$approval_flag" != "--approve-ready" ]; then
  echo "ERROR: moving to Ready requires --approve-ready after explicit human approval of the DoR." >&2
  exit 1
fi

for command_name in gh jq git; do
  if ! command -v "$command_name" >/dev/null 2>&1; then
    echo "ERROR: required command not found: $command_name" >&2
    exit 1
  fi
done

gh auth status >/dev/null
repository=$(gh repo view --json nameWithOwner --jq .nameWithOwner)
owner=${repository%%/*}
repo=${repository#*/}
project_title="$repo - Delivery"

project_number=$(gh project list --owner "$owner" --limit 100 --format json --jq ".projects[] | select(.title == \"$project_title\") | .number" | head -1)
if [ -z "$project_number" ]; then
  echo "ERROR: Project not found: $project_title. Run scripts/configure-github.sh first." >&2
  exit 1
fi

issue_json=$(gh issue view "$issue_number" --repo "$repository" --json id,url,state,stateReason)
issue_url=$(printf '%s' "$issue_json" | jq -r .url)
issue_state=$(printf '%s' "$issue_json" | jq -r .state)
issue_reason=$(printf '%s' "$issue_json" | jq -r '.stateReason // ""')

if [ "$requested_status" != "done" ] && [ "$issue_state" != "OPEN" ]; then
  echo "ERROR: only an open issue can move to $status_name; issue #$issue_number is $issue_state." >&2
  exit 1
fi

if [ "$requested_status" = "done" ]; then
  if [ "$issue_state" != "CLOSED" ] || [ "$issue_reason" != "COMPLETED" ]; then
    echo "ERROR: Done requires issue #$issue_number to be closed as completed, not '${issue_reason:-unknown}'." >&2
    exit 1
  fi

  closing_prs=$(gh api graphql \
    -F owner="$owner" \
    -F repo="$repo" \
    -F issue="$issue_number" \
    -f query='query($owner:String!,$repo:String!,$issue:Int!){repository(owner:$owner,name:$repo){issue(number:$issue){closedByPullRequestsReferences(first:20){nodes{number mergedAt url}}}}}' \
    --jq '.data.repository.issue.closedByPullRequestsReferences.nodes | map(select(.mergedAt != null)) | length')
  if [ "$closing_prs" -lt 1 ]; then
    echo "ERROR: Done requires at least one merged pull request that closed issue #$issue_number." >&2
    exit 1
  fi
fi

project_json=$(gh project view "$project_number" --owner "$owner" --format json)
project_id=$(printf '%s' "$project_json" | jq -r .id)
fields_json=$(gh project field-list "$project_number" --owner "$owner" --limit 100 --format json)
status_field_id=$(printf '%s' "$fields_json" | jq -r '.fields[] | select(.name == "Status") | .id')
status_option_id=$(printf '%s' "$fields_json" | jq -r --arg status "$status_name" '.fields[] | select(.name == "Status") | .options[] | select(.name == $status) | .id')

if [ -z "$status_field_id" ] || [ "$status_field_id" = "null" ] || [ -z "$status_option_id" ] || [ "$status_option_id" = "null" ]; then
  echo "ERROR: Status field or option '$status_name' is missing from Project #$project_number." >&2
  exit 1
fi

items_json=$(gh project item-list "$project_number" --owner "$owner" --limit 1000 --format json)
item_id=$(printf '%s' "$items_json" | jq -r --arg url "$issue_url" '.items[] | select(.content.url == $url) | .id' | head -1)
current_status=$(printf '%s' "$items_json" | jq -r --arg url "$issue_url" '.items[] | select(.content.url == $url) | .status // ""' | head -1)

if [ -n "$current_status" ] && [ "$current_status" != "$status_name" ]; then
  transition="$current_status->$status_name"
  case "$transition" in
    "Inbox->Refinement"|\
    "Refinement->Inbox"|\
    "Refinement->Ready"|\
    "Ready->Refinement"|\
    "Ready->In Progress"|\
    "In Progress->Refinement"|\
    "In Progress->Review"|\
    "Review->In Progress"|\
    "Review->Done"|\
    "Done->Refinement") ;;
    *)
      echo "ERROR: unsupported Project transition: $transition." >&2
      echo "Restore the workflow through an allowed state or resolve the exceptional case explicitly." >&2
      exit 1
      ;;
  esac
fi

if [ -z "$item_id" ] || [ "$item_id" = "null" ]; then
  item_id=$(gh project item-add "$project_number" --owner "$owner" --url "$issue_url" --format json --jq .id)
  echo "Added issue #$issue_number to Project #$project_number."
fi

gh project item-edit \
  --id "$item_id" \
  --project-id "$project_id" \
  --field-id "$status_field_id" \
  --single-select-option-id "$status_option_id" >/dev/null

echo "Issue #$issue_number moved to '$status_name' in Project #$project_number."
