# Inicialização do projeto

> **Para que serve:** permite que pessoas e agentes reconheçam se estão na base genérica ou em um projeto derivado pronto para trabalhar. Após a conclusão, este arquivo permanece como registro histórico.

```yaml
project_initialization:
  status: NOT_STARTED
  completed_at: null
  completed_by: null
  bootstrap_issue: null
  bootstrap_pull_request: null
```

Estados permitidos: `NOT_STARTED`, `IN_PROGRESS` e `COMPLETE`.

## Regra de bloqueio

Implementação de produto ou tecnologia é proibida enquanto:

- o estado não for `COMPLETE`;
- houver `TODO(PROJECT_INIT)` ou placeholder `<PROJECT_...>` material;
- `.ai/vision.md` não tiver aprovação mínima;
- autoridade e política operacional não estiverem registradas.
- `.ai/engineering-context.md` permanecer `NOT_STARTED` ou contiver placeholders materiais.

Descoberta, planejamento do bootstrap e correção dos próprios placeholders continuam permitidos.

## Perguntas mínimas

1. Qual é o nome ou identificador provisório?
2. Que problema ou necessidade motivou o projeto?
3. Quem é afetado e em qual contexto?
4. Qual resultado inicial é desejado?
5. Quais limites ou restrições já são conhecidos?
6. O que é fato, hipótese ou decisão?
7. Quem possui autoridade final?
8. Que informação sensível não pode ser fornecida a assistentes?
9. Qual política valerá para criação de issues, merge e release?
10. O projeto precisa publicar versões e, se precisar, qual esquema adotará?
11. O repositório terá software executável? Se tiver, qual stack mínima atende ao primeiro resultado aprovado?
12. Quais comandos oficiais preparam, executam, formatam, analisam, testam, constroem e verificam segurança?
13. Quais convenções de arquitetura, identificadores, erros, logs, testes e compatibilidade precisam ser registradas?

## Checklist

- [ ] Repositório independente criado a partir do template.
- [ ] GitHub Project, labels e Ruleset configurados com `scripts/configure-github.sh`.
- [ ] Primeira issue de bootstrap criada.
- [ ] Branch `bootstrap/<issue>-<slug>` criada a partir de `main`.
- [ ] Estado alterado para `IN_PROGRESS`.
- [ ] Identidade genérica substituída no `README.md` e em `.ai/vision.md`.
- [ ] Descoberta mínima conduzida e fatos separados de hipóteses.
- [ ] `.ai/vision.md` revisado e aprovado.
- [ ] Autoridade humana e limites de ações externas registrados.
- [ ] Restrições de dados sensíveis, segredos e conteúdo externo revisadas conforme `.ai/security.md`.
- [ ] Política de issues, merge, tags e releases confirmada.
- [ ] `.ai/engineering.md` revisado para compreender a política herdada.
- [ ] `.ai/engineering-context.md` está `CONFIGURED`, ou `NOT_APPLICABLE` com justificativa para repositório sem software executável.
- [ ] Stack, comandos, convenções, testes e requisitos não funcionais aplicáveis estão preenchidos sem placeholders materiais.
- [ ] Decisões estruturais relevantes possuem ADR aprovada ou referência explícita.
- [ ] Exemplos removíveis eliminados.
- [ ] Busca por placeholders obrigatórios executada.
- [ ] PR de bootstrap aberto e ligado à issue.
- [ ] Checks e revisão do bootstrap concluídos.
- [ ] `completed_at`, `completed_by`, issue e PR registrados.
- [ ] Estado alterado para `COMPLETE` no último commit do bootstrap.

## Caminho automatizado recomendado

Depois de criar e clonar o repositório derivado, execute:

```sh
./scripts/start-project.sh
```

Esse helper realiza os passos mecânicos até `IN_PROGRESS`. Ele exige confirmação do repositório-alvo e aprovação humana explícita antes de mover a issue de bootstrap para `Ready`. Se for interrompido, não repita cegamente: consulte a issue criada, o Project, a branch atual e use os helpers individuais documentados em `AGENTS.md`.

## Critério de conclusão

O bootstrap termina quando o repositório tem identidade própria, visão mínima aprovada, autoridade registrada, nenhum placeholder material, política operacional definida, contexto de engenharia aprovado e configuração remota verificada. A arquitetura deve estar definida apenas no nível necessário para começar com segurança; decisões ainda não necessárias não devem ser antecipadas.
