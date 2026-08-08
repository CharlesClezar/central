# Integração com GitHub

> **Para que serve:** explica os arquivos que o GitHub descobre em locais convencionais e que, por isso, não podem ser movidos para `.ai/`.

- `ISSUE_TEMPLATE/`: formulários estruturados para cada tipo de trabalho.
- `pull_request_template.md`: contexto mínimo e Definition of Done do PR.
- `workflows/governance.yml`: valida estrutura, links Markdown, estado do bootstrap, contexto de engenharia, branch, issue de origem e completude do PR pronto para revisão.
- `workflows/create-release-tag.yml`: cria tag SemVer autorizada a partir de `main`.
- `workflows/release.yml`: valida a tag e cria GitHub Release.
- `rulesets/`: cargas JSON aplicadas por `scripts/configure-github.sh`.

A metodologia canônica permanece em `.ai/`; estes arquivos são adaptadores ou mecanismos de aplicação. Checks de linguagem, build, testes, segurança e deploy só devem ser acrescentados depois que o projeto derivado definir sua stack e política de publicação.

Draft PRs precisam apenas de rastreabilidade válida e podem conter checklist incompleto. Ao marcar um PR como pronto para revisão, a governança exige todas as seções, remoção dos placeholders principais e conclusão do checklist obrigatório.

Actions externas são fixadas por SHA completo e acompanhadas da versão em comentário. Atualizações seguem issue, branch e PR normais; bots de atualização não são ativados enquanto não preservarem essa rastreabilidade.
