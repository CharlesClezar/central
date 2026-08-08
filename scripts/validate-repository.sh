#!/bin/sh
# Purpose: validate the tool-neutral structure and initialization state of this repository.

set -eu

repo_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$repo_root"

required_files="
README.md
AGENTS.md
CLAUDE.md
.blueprint/CHANGELOG.md
.blueprint/source
.blueprint/version
.blueprint/manifest.json
.ai/README.md
.ai/project-init.md
.ai/vision.md
.ai/workflow.md
.ai/backlog.md
.ai/interaction-guide.md
.ai/security.md
.ai/engineering.md
.ai/engineering-context.md
.ai/blueprint-updates.md
.ai/github-setup.md
.ai/decisions/README.md
.github/pull_request_template.md
scripts/start-project.sh
scripts/doctor.sh
scripts/check-blueprint-update.sh
"

failed=0

for required_file in $required_files; do
  if [ ! -s "$required_file" ]; then
    echo "ERROR: required file is missing or empty: $required_file" >&2
    failed=1
  fi
done

status=$(sed -n 's/^[[:space:]]*status:[[:space:]]*\([A-Z_]*\)[[:space:]]*$/\1/p' .ai/project-init.md | head -1)

case "$status" in
  NOT_STARTED|IN_PROGRESS)
    echo "INFO: project initialization status is $status; product implementation remains blocked."
    ;;
  COMPLETE)
    placeholder_files="README.md AGENTS.md CLAUDE.md .ai/vision.md .ai/engineering-context.md"
    if grep -En 'TODO\(PROJECT_INIT\)|<PROJECT_[A-Z_]+>|<AFFECTED_CONTEXT_OR_USERS>|<DESIRED_OUTCOME>|<KNOWN_BOUNDARIES>|<DECISION_AUTHORITY>|EXAMPLE_ONLY' $placeholder_files; then
      echo "ERROR: material initialization placeholders remain in an initialized project." >&2
      failed=1
    fi
    if grep -Eq 'completed_at:[[:space:]]*null|completed_by:[[:space:]]*null|bootstrap_issue:[[:space:]]*null|bootstrap_pull_request:[[:space:]]*null' .ai/project-init.md; then
      echo "ERROR: completed initialization must record date, authority, issue, and pull request." >&2
      failed=1
    fi
    engineering_status=$(sed -n 's/^[[:space:]]*status:[[:space:]]*\([A-Z_]*\)[[:space:]]*$/\1/p' .ai/engineering-context.md | head -1)
    case "$engineering_status" in
      CONFIGURED|NOT_APPLICABLE) ;;
      *)
        echo "ERRO: a inicialização concluída exige contexto de engenharia CONFIGURED ou NOT_APPLICABLE; encontrado '${engineering_status:-ausente}'." >&2
        failed=1
        ;;
    esac
    ;;
  *)
    echo "ERROR: invalid or missing project initialization status: ${status:-<missing>}" >&2
    failed=1
    ;;
esac

if find .github/ISSUE_TEMPLATE -type f -name '*.yml' -maxdepth 1 | grep -q .; then
  :
else
  echo "ERROR: no issue forms found in .github/ISSUE_TEMPLATE." >&2
  failed=1
fi

if ! grep -Eq '^[0-9]+\.[0-9]+\.[0-9]+$' .blueprint/version; then
  echo "ERRO: .blueprint/version deve conter MAJOR.MINOR.PATCH sem prefixo." >&2
  failed=1
fi

if ! grep -Eq '^[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+$' .blueprint/source; then
  echo "ERRO: .blueprint/source deve conter owner/repository." >&2
  failed=1
fi

if [ ! -x scripts/check-blueprint-update.sh ]; then
  echo "ERRO: scripts/check-blueprint-update.sh precisa ser executável." >&2
  failed=1
fi

if ! command -v python3 >/dev/null 2>&1; then
  echo "ERROR: python3 is required for local Markdown link validation." >&2
  failed=1
else
  if ! python3 -m json.tool .blueprint/manifest.json >/dev/null; then
    echo "ERRO: .blueprint/manifest.json não contém JSON válido." >&2
    failed=1
  fi
  if ! python3 scripts/validate-docs.py; then
    failed=1
  fi
fi

if [ "$failed" -ne 0 ]; then
  exit 1
fi

echo "Repository governance validation passed."
