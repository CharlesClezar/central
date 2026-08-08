#!/bin/sh
# Purpose: apply or audit reproducible GitHub settings for a derived Blueprint repository.

set -eu

repo_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$repo_root"

mode="apply"
assume_yes=false
case "${1:-}" in
  "") ;;
  --yes) assume_yes=true ;;
  --check) mode="check" ;;
  --dry-run) mode="dry-run" ;;
  *) echo "Usage: $0 [--yes|--check|--dry-run]" >&2; exit 2 ;;
esac

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

echo "Target repository: $repository"
echo "Owner for Project: $owner"

if [ "$mode" = "dry-run" ]; then
  cat <<EOF
DRY RUN — no remote changes will be made.

Would configure:
  - main as default branch
  - issues, repository Projects, auto-merge and update-branch enabled
  - squash and rebase merge enabled; merge commits disabled
  - automatic branch deletion after merge
  - wiki disabled
  - vulnerability alerts when supported
  - six Blueprint labels
  - Project '$project_title' with Status, Priority and Type
  - main and version-tag Rulesets
  - native Project workflows left for explicit UI review
EOF
  exit 0
fi

audit_configuration() {
  failures=0

  pass() { echo "PASS  $1"; }
  warn() { echo "WARN  $1"; }
  fail() { echo "FAIL  $1"; failures=$((failures + 1)); }

  repo_json=$(gh repo view "$repository" --json defaultBranchRef,deleteBranchOnMerge,hasIssuesEnabled,hasProjectsEnabled,hasWikiEnabled,mergeCommitAllowed,rebaseMergeAllowed,squashMergeAllowed)

  check_json() {
    expression=$1
    message=$2
    if printf '%s' "$repo_json" | jq -e "$expression" >/dev/null; then pass "$message"; else fail "$message"; fi
  }

  check_json '.defaultBranchRef.name == "main"' "Default branch is main"
  check_json '.deleteBranchOnMerge == true' "Head branches are deleted after merge"
  check_json '.hasIssuesEnabled == true' "Issues are enabled"
  check_json '.hasProjectsEnabled == true' "Repository Projects integration is enabled"
  check_json '.hasWikiEnabled == false' "Wiki is disabled"
  check_json '.mergeCommitAllowed == false' "Merge commits are disabled"
  check_json '.rebaseMergeAllowed == true' "Rebase merge is enabled"
  check_json '.squashMergeAllowed == true' "Squash merge is enabled"

  auto_merge=$(gh api graphql -F owner="$owner" -F repo="$repo" -f query='query($owner:String!,$repo:String!){repository(owner:$owner,name:$repo){autoMergeAllowed}}' --jq '.data.repository.autoMergeAllowed')
  if [ "$auto_merge" = "true" ]; then pass "Auto-merge is enabled"; else fail "Auto-merge is enabled"; fi

  if gh api "repos/$repository/vulnerability-alerts" >/dev/null 2>&1; then
    pass "Vulnerability alerts are enabled"
  else
    warn "Vulnerability alerts are unavailable or disabled"
  fi

  labels_json=$(gh label list --repo "$repository" --limit 100 --json name)
  for label_name in type:feature type:bug type:technical type:research type:documentation blocked; do
    if printf '%s' "$labels_json" | jq -e --arg name "$label_name" '.[] | select(.name == $name)' >/dev/null; then
      pass "Label exists: $label_name"
    else
      fail "Label exists: $label_name"
    fi
  done

  project_number=$(gh project list --owner "$owner" --limit 100 --format json --jq ".projects[] | select(.title == \"$project_title\") | .number" | head -1)
  if [ -z "$project_number" ]; then
    fail "Project exists: $project_title"
  else
    pass "Project exists: $project_title (#$project_number)"
    fields_json=$(gh project field-list "$project_number" --owner "$owner" --limit 100 --format json)
    for field_name in Status Priority Type; do
      if printf '%s' "$fields_json" | jq -e --arg name "$field_name" '.fields[] | select(.name == $name)' >/dev/null; then
        pass "Project field exists: $field_name"
      else
        fail "Project field exists: $field_name"
      fi
    done

    status_names=$(printf '%s' "$fields_json" | jq -r '.fields[] | select(.name == "Status") | .options[].name' 2>/dev/null || true)
    desired_status_names=$(printf '%s\n' "Inbox" "Refinement" "Ready" "In Progress" "Review" "Done")
    if [ "$status_names" = "$desired_status_names" ]; then pass "Project Status options match Blueprint"; else fail "Project Status options match Blueprint"; fi
  fi

  if rulesets_json=$(gh api "repos/$repository/rulesets?includes_parents=false" 2>/dev/null); then
    for ruleset_name in "Blueprint - protect main" "Blueprint - immutable version tags"; do
      if printf '%s' "$rulesets_json" | jq -e --arg name "$ruleset_name" '.[] | select(.name == $name and .enforcement == "active")' >/dev/null; then
        pass "Active Ruleset: $ruleset_name"
      else
        fail "Active Ruleset: $ruleset_name"
      fi
    done
  else
    fail "Rulesets API is available for this repository and account plan"
  fi

  warn "Native Project workflows cannot be fully audited by the stable gh CLI; verify them in Project → Workflows"

  if [ "$failures" -gt 0 ]; then
    echo "GitHub configuration audit failed with $failures problem(s)." >&2
    return 1
  fi
  echo "GitHub configuration audit passed."
}

if [ "$mode" = "check" ]; then
  audit_configuration
  exit $?
fi

if [ "$assume_yes" != true ]; then
  printf "Create or update Blueprint GitHub configuration for this target? [y/N] "
  read -r answer
  case "$answer" in
    y|Y|yes|YES) ;;
    *) echo "Cancelled without remote changes."; exit 0 ;;
  esac
fi

gh repo edit "$repository" \
  --default-branch main \
  --delete-branch-on-merge \
  --allow-update-branch \
  --enable-issues \
  --enable-projects \
  --enable-wiki=false \
  --enable-merge-commit=false \
  --enable-rebase-merge \
  --enable-squash-merge \
  --squash-merge-commit-message pr-title-description

if gh api --method PUT "repos/$repository/vulnerability-alerts" >/dev/null 2>&1; then
  echo "Enabled vulnerability alerts."
else
  echo "WARN: vulnerability alerts could not be enabled on the current repository or plan." >&2
fi

ensure_label() {
  label_name=$1
  color=$2
  description=$3
  if gh label list --repo "$repository" --search "$label_name" --json name --jq ".[] | select(.name == \"$label_name\") | .name" | grep -qx "$label_name"; then
    gh label edit "$label_name" --repo "$repository" --color "$color" --description "$description"
  else
    gh label create "$label_name" --repo "$repository" --color "$color" --description "$description"
  fi
}

ensure_label "type:feature" "1D76DB" "Novo comportamento ou capacidade"
ensure_label "type:bug" "D73A4A" "Correção de comportamento incorreto"
ensure_label "type:technical" "5319E7" "Manutenção ou melhoria interna verificável"
ensure_label "type:research" "FBCA04" "Investigação limitada para apoiar decisão"
ensure_label "type:documentation" "0075CA" "Documentação como resultado principal"
ensure_label "blocked" "B60205" "Item impedido por dependência ou decisão explícita"

project_number=$(gh project list --owner "$owner" --limit 100 --format json --jq ".projects[] | select(.title == \"$project_title\") | .number" | head -1)
if [ -z "$project_number" ]; then
  project_number=$(gh project create --owner "$owner" --title "$project_title" --format json --jq .number)
  echo "Created Project #$project_number: $project_title"
else
  echo "Using existing Project #$project_number: $project_title"
fi
gh project link "$project_number" --owner "$owner" --repo "$repo" >/dev/null

ensure_project_field() {
  field_name=$1
  options=$2
  field_id=$(gh project field-list "$project_number" --owner "$owner" --format json --jq ".fields[] | select(.name == \"$field_name\") | .id" | head -1)
  if [ -z "$field_id" ]; then
    gh project field-create "$project_number" --owner "$owner" --name "$field_name" --data-type SINGLE_SELECT --single-select-options "$options" >/dev/null
    echo "Created Project field: $field_name"
  else
    echo "Project field already exists: $field_name"
  fi
}

ensure_project_field "Priority" "P0,P1,P2,P3"
ensure_project_field "Type" "Feature,Bug,Technical,Research,Documentation"

fields_json=$(gh project field-list "$project_number" --owner "$owner" --limit 100 --format json)
status_id=$(printf '%s' "$fields_json" | jq -r '.fields[] | select(.name == "Status") | .id')
status_names=$(printf '%s' "$fields_json" | jq -r '.fields[] | select(.name == "Status") | .options[].name')
desired_status_names=$(printf '%s\n' "Inbox" "Refinement" "Ready" "In Progress" "Review" "Done")
default_status_names=$(printf '%s\n' "Todo" "In Progress" "Done")

if [ "$status_names" = "$desired_status_names" ]; then
  echo "Project Status options already configured."
elif [ "$status_names" = "$default_status_names" ]; then
  status_payload=$(mktemp "${TMPDIR:-/tmp}/blueprint-project-status.XXXXXX")
  trap 'rm -f "$status_payload"' EXIT HUP INT TERM
  jq -n --arg field_id "$status_id" '{
    query: "mutation($input: UpdateProjectV2FieldInput!) { updateProjectV2Field(input: $input) { projectV2Field { ... on ProjectV2SingleSelectField { id name } } } }",
    variables: {input: {fieldId: $field_id, singleSelectOptions: [
      {name:"Inbox", color:"GRAY", description:"Capturado; ainda não aprovado nem refinado"},
      {name:"Refinement", color:"YELLOW", description:"Em esclarecimento ou decomposição"},
      {name:"Ready", color:"BLUE", description:"DoR satisfeita e aprovação humana registrada"},
      {name:"In Progress", color:"ORANGE", description:"Implementação ativa"},
      {name:"Review", color:"PURPLE", description:"PR em revisão ou validação"},
      {name:"Done", color:"GREEN", description:"DoD satisfeita"}
    ]}}
  }' > "$status_payload"
  gh api graphql --input "$status_payload" >/dev/null
  rm -f "$status_payload"
  trap - EXIT HUP INT TERM
  echo "Configured Project Status options."
else
  echo "ERROR: existing Status options are customized; refusing to overwrite them:" >&2
  printf '%s\n' "$status_names" >&2
  exit 1
fi

apply_ruleset() {
  ruleset_name=$1
  ruleset_file=$2
  ruleset_id=$(printf '%s' "$rulesets_json" | jq -r --arg name "$ruleset_name" '.[] | select(.name == $name) | .id' | head -1)
  if [ -z "$ruleset_id" ]; then
    gh api --method POST "repos/$repository/rulesets" --input "$ruleset_file" >/dev/null
    echo "Created Ruleset: $ruleset_name"
  else
    gh api --method PUT "repos/$repository/rulesets/$ruleset_id" --input "$ruleset_file" >/dev/null
    echo "Updated Ruleset #$ruleset_id: $ruleset_name"
  fi
}

if ! rulesets_json=$(gh api "repos/$repository/rulesets?includes_parents=false"); then
  echo "ERROR: Rulesets are unavailable for this repository or account plan." >&2
  echo "Use a public repository or a GitHub plan that supports Rulesets for private repositories, then rerun this script." >&2
  exit 1
fi

apply_ruleset "Blueprint - protect main" ".github/rulesets/main.json"
apply_ruleset "Blueprint - immutable version tags" ".github/rulesets/version-tags.json"

# GitHub requires a protection rule or Ruleset before auto-merge can be enabled.
gh repo edit "$repository" --enable-auto-merge

echo "GitHub configuration applied."
echo "Project #$project_number requires native workflow review in the GitHub UI:"
echo "  - Auto-add: repo:$repository is:issue"
echo "  - Item added: Status = Inbox"
echo "  - Completed issue closed: Status = Done"
echo "  - Disable merged-PR workflow when PR cards are not used"
echo "Run './scripts/configure-github.sh --check' to audit reproducible settings."
