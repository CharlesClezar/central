#!/bin/sh
# Purpose: perform a read-only audit of local Blueprint state and remote GitHub configuration.

set -u

repo_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$repo_root"

failures=0
warnings=0
pass() { echo "PASS  $1"; }
warn() { echo "WARN  $1"; warnings=$((warnings + 1)); }
fail() { echo "FAIL  $1"; failures=$((failures + 1)); }

for command_name in git gh jq python3; do
  if command -v "$command_name" >/dev/null 2>&1; then pass "Command available: $command_name"; else fail "Command available: $command_name"; fi
done

if [ ! -d .git ]; then
  fail "Git repository detected"
  echo "Doctor finished: $failures failure(s), $warnings warning(s)."
  exit 1
fi
pass "Git repository detected"

branch=$(git branch --show-current)
pass "Current branch: ${branch:-detached HEAD}"

if [ -z "$(git status --porcelain)" ]; then pass "Working tree is clean"; else warn "Working tree has local changes"; fi

if origin=$(git remote get-url origin 2>/dev/null); then pass "Origin configured: $origin"; else fail "Origin is configured"; fi

if ./scripts/validate-repository.sh; then pass "Local repository governance"; else fail "Local repository governance"; fi

if gh auth status >/dev/null 2>&1; then
  pass "GitHub CLI authentication"
  if gh repo view --json nameWithOwner >/dev/null 2>&1; then
    repository=$(gh repo view --json nameWithOwner --jq .nameWithOwner)
    pass "GitHub repository resolved: $repository"
    if ./scripts/configure-github.sh --check; then pass "Remote GitHub configuration"; else fail "Remote GitHub configuration"; fi
  else
    fail "Current checkout resolves to a GitHub repository"
  fi
else
  fail "GitHub CLI authentication"
fi

warn "Native Project workflows require visual verification in Project → Workflows"
echo "Doctor finished: $failures failure(s), $warnings warning(s)."
[ "$failures" -eq 0 ]
