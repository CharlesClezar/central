#!/bin/sh
# Purpose: safely prepare a newly generated Blueprint repository for AI-assisted project discovery.

set -eu

repo_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$repo_root"

for command_name in git gh jq python3; do
  if ! command -v "$command_name" >/dev/null 2>&1; then
    echo "ERROR: required command not found: $command_name" >&2
    exit 1
  fi
done

if [ ! -d .git ]; then
  echo "ERROR: this directory is not a cloned Git repository." >&2
  echo "Create it with: gh repo create OWNER/PROJECT --template OWNER/blueprint --private --clone" >&2
  exit 1
fi

if [ -n "$(git status --porcelain)" ]; then
  echo "ERROR: working tree must be clean before starting the bootstrap." >&2
  exit 1
fi

initialization_status=$(sed -n 's/^[[:space:]]*status:[[:space:]]*\([A-Z_]*\)[[:space:]]*$/\1/p' .ai/project-init.md | head -1)
current_branch=$(git branch --show-current)

if [ "$initialization_status" = "IN_PROGRESS" ]; then
  bootstrap_issue=$(sed -n 's/^[[:space:]]*bootstrap_issue:[[:space:]]*\([^[:space:]]*\)[[:space:]]*$/\1/p' .ai/project-init.md | head -1)
  echo "Bootstrap is already IN_PROGRESS on branch '$current_branch'."
  echo "Recorded issue: ${bootstrap_issue:-unknown}"
  echo "Run ./scripts/doctor.sh, inspect the issue/branch/PR, and ask the AI to resume instead of creating another bootstrap."
  exit 0
fi

if [ "$initialization_status" = "COMPLETE" ]; then
  echo "Project bootstrap is already COMPLETE. Run ./scripts/doctor.sh to audit it."
  exit 0
fi

if [ "$initialization_status" != "NOT_STARTED" ]; then
  echo "ERROR: invalid initialization status '${initialization_status:-<missing>}'." >&2
  exit 1
fi

if [ "$current_branch" != "main" ]; then
  echo "ERROR: a NOT_STARTED bootstrap must begin from main; current branch is '$current_branch'." >&2
  exit 1
fi

gh auth status >/dev/null
repository=$(gh repo view --json nameWithOwner --jq .nameWithOwner)
repository_url=$(gh repo view --json url --jq .url)
origin_url=$(git remote get-url origin)

echo "Repository detected: $repository"
echo "GitHub URL: $repository_url"
echo "Origin: $origin_url"
echo
echo "This command is only for a NEW DERIVED PROJECT, never for the Blueprint base."
printf "Type the complete repository name '%s' to confirm the target: " "$repository"
read -r confirmed_repository
if [ "$confirmed_repository" != "$repository" ]; then
  echo "Cancelled: repository confirmation did not match. No remote changes were requested by this script." >&2
  exit 1
fi

echo
echo "Configuring labels, Project fields, main protection, and immutable version tags..."
./scripts/configure-github.sh

issue_body=$(mktemp "${TMPDIR:-/tmp}/blueprint-bootstrap-issue.XXXXXX")
trap 'rm -f "$issue_body"' EXIT HUP INT TERM

cat > "$issue_body" <<'EOF'
## Contexto

Este repositório foi criado a partir do Blueprint e precisa adquirir identidade, visão mínima e configuração operacional próprias antes de qualquer implementação de produto.

## Objetivo verificável

Concluir o checklist de `.ai/project-init.md`, remover placeholders materiais e deixar o repositório derivado apto para descoberta e planejamento rastreáveis.

## Escopo

- Confirmar repositório e autoridade do projeto.
- Preencher identidade e visão mínima aprovadas.
- Revisar segurança, dados e ações externas.
- Confirmar política de issues, merge, tags e releases.
- Definir e aprovar o contexto de engenharia, ou justificar que não se aplica.
- Validar documentação, links e governança.

## Fora de escopo

- Definir funcionalidades ainda não descobertas.
- Escrever código de produção.

## Critérios de aceite

- [ ] `.ai/project-init.md` está `COMPLETE` e registra data, responsável, issue e PR.
- [ ] `.ai/vision.md` contém somente fatos, hipóteses e decisões identificadas corretamente.
- [ ] Não restam placeholders materiais.
- [ ] `.ai/engineering-context.md` está preenchido e aprovado como `CONFIGURED` ou `NOT_APPLICABLE`.
- [ ] Configuração remota e workflows nativos do Project foram revisados.
- [ ] `./scripts/validate-repository.sh` passa.
- [ ] Draft PR foi preenchido e preparado para revisão.

## Dependências e decisões

- Respostas e aprovações do usuário durante o bootstrap.

## Riscos, reversibilidade e evidência esperada

- Não inserir segredos ou dados sensíveis nos artefatos.
- Evidência: checks do PR, revisão dos documentos e validação local bem-sucedida.
EOF

existing_issue=$(gh issue list --repo "$repository" --state open --label "type:technical" --limit 100 --json number,title,url --jq '.[] | select(.title == "[Technical]: Inicializar o projeto derivado") | [.number,.url] | @tsv' | head -1)

if [ -n "$existing_issue" ]; then
  issue_number=$(printf '%s\n' "$existing_issue" | cut -f1)
  issue_url=$(printf '%s\n' "$existing_issue" | cut -f2)
  echo "Reusing existing bootstrap issue #$issue_number: $issue_url"
  issue_created=false
else
  issue_url=$(gh issue create \
    --title "[Technical]: Inicializar o projeto derivado" \
    --label "type:technical" \
    --body-file "$issue_body")
  issue_number=${issue_url##*/}
  issue_created=true
  echo "Created bootstrap issue #$issue_number: $issue_url"
fi
rm -f "$issue_body"
trap - EXIT HUP INT TERM

if [ "$issue_created" = true ]; then
  ./scripts/project-item.sh "$issue_number" inbox
fi
./scripts/project-item.sh "$issue_number" refinement

echo
echo "Review the bootstrap issue before approving it:"
echo "  $issue_url"
printf "Approve this bootstrap issue as Ready? [y/N] "
read -r approval
case "$approval" in
  y|Y|yes|YES) ;;
  *)
    echo "Stopped safely with issue #$issue_number in Refinement."
    echo "After approval, continue with:"
    echo "  ./scripts/project-item.sh $issue_number ready --approve-ready"
    echo "  git switch -c bootstrap/$issue_number-inicializar-projeto"
    echo "  ./scripts/bootstrap-local.sh $issue_number"
    exit 0
    ;;
esac

./scripts/project-item.sh "$issue_number" ready --approve-ready

git pull --ff-only origin main
branch="bootstrap/$issue_number-inicializar-projeto"
if git show-ref --verify --quiet "refs/heads/$branch"; then
  git switch "$branch"
elif git ls-remote --exit-code --heads origin "$branch" >/dev/null 2>&1; then
  git switch --track "origin/$branch"
else
  git switch -c "$branch"
fi
./scripts/bootstrap-local.sh "$issue_number"
./scripts/project-item.sh "$issue_number" in-progress

echo
echo "Bootstrap mechanics completed. Current branch: $branch"
echo "Next, open your AI tool in this directory and request:"
echo "  Conduza a inicialização da issue #$issue_number conforme AGENTS.md, .ai/project-init.md, .ai/engineering.md e .ai/engineering-context.md."
echo "The AI must ask for project decisions, update affected artifacts, validate, and prepare a draft PR."
