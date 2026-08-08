#!/bin/sh
# Purpose: start a derived project's bootstrap without inventing its product-specific answers.

set -eu

repo_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$repo_root"

issue_number=${1:-}

if ! printf '%s' "$issue_number" | grep -Eq '^[0-9]+$'; then
  echo "Usage: $0 <bootstrap-issue-number>" >&2
  exit 2
fi

if [ ! -d .git ]; then
  echo "ERROR: run this script inside the cloned derived repository." >&2
  exit 1
fi

branch=$(git branch --show-current)
expected_prefix="bootstrap/$issue_number-"

case "$branch" in
  "$expected_prefix"*) ;;
  *)
    echo "ERROR: current branch '$branch' must start with '$expected_prefix'." >&2
    exit 1
    ;;
esac

current_status=$(sed -n 's/^[[:space:]]*status:[[:space:]]*\([A-Z_]*\)[[:space:]]*$/\1/p' .ai/project-init.md | head -1)
if [ "$current_status" != "NOT_STARTED" ]; then
  echo "ERROR: expected NOT_STARTED, found '${current_status:-<missing>}'." >&2
  exit 1
fi

tmp_file=$(mktemp "${TMPDIR:-/tmp}/blueprint-init.XXXXXX")
trap 'rm -f "$tmp_file"' EXIT HUP INT TERM

awk -v issue="$issue_number" '
  /^[[:space:]]*status:[[:space:]]*NOT_STARTED[[:space:]]*$/ { sub(/NOT_STARTED/, "IN_PROGRESS") }
  /^[[:space:]]*bootstrap_issue:[[:space:]]*null[[:space:]]*$/ { sub(/null/, issue) }
  { print }
' .ai/project-init.md > "$tmp_file"
mv "$tmp_file" .ai/project-init.md
trap - EXIT HUP INT TERM

echo "Bootstrap marked IN_PROGRESS for issue #$issue_number."
echo "Preencha .ai/vision.md, .ai/engineering-context.md e o checklist de .ai/project-init.md; não invente respostas ausentes."
echo "Before the final bootstrap commit, record the PR number, completion date and authority, then set status to COMPLETE."
