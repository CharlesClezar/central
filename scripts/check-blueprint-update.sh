#!/bin/sh
# Para que serve: compara, sem alterar estado, a versão instalada do Blueprint com a release mais recente da origem registrada.

set -eu

repo_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$repo_root"

output_json=false
case "${1:-}" in
  "") ;;
  --json) output_json=true ;;
  *) echo "Uso: $0 [--json]" >&2; exit 2 ;;
esac

for command_name in gh jq; do
  if ! command -v "$command_name" >/dev/null 2>&1; then
    echo "ERRO: comando obrigatório não encontrado: $command_name" >&2
    exit 1
  fi
done

if [ ! -s .blueprint/source ] || [ ! -s .blueprint/version ]; then
  echo "ERRO: origem ou versão do Blueprint ausente em .blueprint/." >&2
  echo "Este projeto pode anteceder o mecanismo de atualização; consulte .ai/blueprint-updates.md." >&2
  exit 1
fi

source_repository=$(tr -d '[:space:]' < .blueprint/source)
installed_version=$(tr -d '[:space:]' < .blueprint/version)

valid_version() {
  printf '%s' "$1" | grep -Eq '^[0-9]+\.[0-9]+\.[0-9]+$'
}

if ! printf '%s' "$source_repository" | grep -Eq '^[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+$'; then
  echo "ERRO: origem inválida em .blueprint/source: $source_repository" >&2
  exit 1
fi

if ! valid_version "$installed_version"; then
  echo "ERRO: versão instalada inválida em .blueprint/version: $installed_version" >&2
  exit 1
fi

gh auth status >/dev/null
if ! release_json=$(gh release view --repo "$source_repository" --json tagName,publishedAt,url 2>/dev/null); then
  echo "ERRO: nenhuma release publicada foi encontrada em $source_repository." >&2
  echo "A origem precisa publicar uma tag SemVer antes que derivados possam comparar versões." >&2
  exit 1
fi

latest_tag=$(printf '%s' "$release_json" | jq -r .tagName)
latest_version=${latest_tag#v}
release_url=$(printf '%s' "$release_json" | jq -r .url)
published_at=$(printf '%s' "$release_json" | jq -r .publishedAt)

if ! valid_version "$latest_version" || [ "$latest_tag" != "v$latest_version" ]; then
  echo "ERRO: a release mais recente não usa tag vMAJOR.MINOR.PATCH: $latest_tag" >&2
  exit 1
fi

comparison=$(awk -v installed="$installed_version" -v latest="$latest_version" '
  BEGIN {
    split(installed, a, "."); split(latest, b, ".");
    for (i = 1; i <= 3; i++) {
      if ((a[i] + 0) < (b[i] + 0)) { print "update_available"; exit }
      if ((a[i] + 0) > (b[i] + 0)) { print "local_ahead"; exit }
    }
    print "up_to_date"
  }
')

if [ "$output_json" = true ]; then
  jq -n \
    --arg source "$source_repository" \
    --arg installed "$installed_version" \
    --arg latest "$latest_version" \
    --arg status "$comparison" \
    --arg release_url "$release_url" \
    --arg published_at "$published_at" \
    '{source: $source, installed_version: $installed, latest_version: $latest, status: $status, release_url: $release_url, published_at: $published_at}'
  exit 0
fi

echo "Origem do Blueprint: $source_repository"
echo "Versão instalada: $installed_version"
echo "Versão publicada mais recente: $latest_version"
echo "Release: $release_url"

case "$comparison" in
  update_available)
    echo "ATUALIZAÇÃO DISPONÍVEL: peça à IA para analisar mudanças e impacto antes de aplicar."
    ;;
  up_to_date)
    echo "ATUALIZADO: este projeto usa a versão publicada mais recente."
    ;;
  local_ahead)
    echo "AVISO: a versão instalada é superior à release publicada; verifique origem e processo de publicação."
    ;;
esac
