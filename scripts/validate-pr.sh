#!/bin/sh
# Purpose: validate that a pull request follows branch and issue traceability rules.

set -eu

head_ref=${PR_HEAD_REF:-}
base_ref=${PR_BASE_REF:-}
body=${PR_BODY:-}
repository=${GITHUB_REPOSITORY:-}
pr_number=${PR_NUMBER:-}
draft=${PR_DRAFT:-true}

if [ -z "$head_ref" ] || [ -z "$base_ref" ]; then
  echo "ERRO: PR_HEAD_REF e PR_BASE_REF são obrigatórios." >&2
  exit 1
fi

if [ "$base_ref" != "main" ]; then
  echo "ERRO: pull requests devem apontar para main; recebido '$base_ref'." >&2
  exit 1
fi

if ! printf '%s\n' "$head_ref" | grep -Eq '^(bootstrap|feature|bugfix|technical|docs|research)/[0-9]+-[a-z0-9]+([a-z0-9-]*[a-z0-9])?$'; then
  echo "ERRO: a branch '$head_ref' não segue <tipo>/<issue>-<slug>." >&2
  exit 1
fi

issue_number=$(printf '%s\n' "$head_ref" | sed -E 's#^[^/]+/([0-9]+)-.*#\1#')

if ! printf '%s\n' "$body" | grep -Eiq "(^|[^0-9])(closes|closed|close|fixes|fixed|fix|resolves|resolved|resolve|relates to)[[:space:]]+#${issue_number}([^0-9]|$)"; then
  echo "ERRO: o corpo do PR deve referenciar explicitamente a issue #$issue_number com Closes/Fixes/Resolves ou Relates to." >&2
  exit 1
fi

if [ -n "${GH_TOKEN:-}" ] && [ -n "$repository" ] && command -v gh >/dev/null 2>&1; then
  issue_data=$(gh api "repos/$repository/issues/$issue_number" --jq '[has("pull_request"), .state] | @tsv')
  is_pull_request=$(printf '%s\n' "$issue_data" | cut -f1)
  issue_state=$(printf '%s\n' "$issue_data" | cut -f2)
  if [ "$is_pull_request" = "true" ]; then
    echo "ERRO: #$issue_number aponta para um pull request, não para uma issue." >&2
    exit 1
  fi
  if [ "$issue_state" != "open" ]; then
    pr_merged=false
    if printf '%s' "$pr_number" | grep -Eq '^[0-9]+$'; then
      merged_at=$(gh api "repos/$repository/pulls/$pr_number" --jq '.merged_at // ""')
      if [ -n "$merged_at" ]; then
        pr_merged=true
      fi
    fi

    if [ "$pr_merged" != true ]; then
      echo "ERRO: a issue de origem #$issue_number deve estar aberta enquanto o pull request #${pr_number:-desconhecido} estiver ativo." >&2
      exit 1
    fi

    echo "INFO: a issue de origem #$issue_number está fechada porque o pull request #$pr_number já foi integrado."
  fi
fi

if [ "$draft" = "false" ]; then
  required_headings="
## Issue
## Resumo
## Escopo
## Evidências
## Documentação e decisões
## Análise de impacto e consistência
## Riscos, limitações e follow-ups
## Segurança
## Engenharia
## Checklist
"

  while IFS= read -r heading; do
    [ -z "$heading" ] && continue
    if ! printf '%s\n' "$body" | grep -Fqx "$heading"; then
      echo "ERRO: o PR pronto para revisão não contém o título obrigatório: $heading" >&2
      exit 1
    fi
  done <<EOF
$required_headings
EOF

  if printf '%s\n' "$body" | grep -Eq '#<número>|<O que mudou e por quê>|<item ou “Nenhum conhecido”>'; then
    echo "ERRO: o PR pronto para revisão ainda contém placeholders do template." >&2
    exit 1
  fi

  required_checks="
A issue estava aprovada em \`Ready\` antes da implementação, ou este é o bootstrap inicial.
Critérios de aceite atendidos.
Testes relevantes atualizados e executados.
Documentação afetada atualizada.
Fonte oficial e todas as representações relacionadas permanecem coerentes.
Referências foram pesquisadas novamente após a alteração.
Impactos de segurança, dados, dependências, permissões e ações externas foram avaliados.
Política de engenharia e contexto específico da stack foram respeitados.
Política de integração foi verificada; auto-merge só será solicitado se estiver autorizado.
Nenhuma mudança fora do escopo.
Limitações e verificações não executadas declaradas.
Branch segue o padrão e será removida após o merge.
"

  while IFS= read -r check_text; do
    [ -z "$check_text" ] && continue
    if ! printf '%s\n' "$body" | grep -Fqi -- "- [x] $check_text"; then
      echo "ERRO: o PR pronto para revisão possui item obrigatório desmarcado: $check_text" >&2
      exit 1
    fi
  done <<EOF
$required_checks
EOF
fi

echo "Validação de rastreabilidade do pull request aprovada para a issue #$issue_number."
