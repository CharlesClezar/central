# Mapa da metodologia

> **Para que serve:** orienta pessoas e agentes sobre onde encontrar cada informação durável do projeto e evita duplicação entre conversas, documentos, issues e PRs.

## Fontes oficiais

| Informação | Fonte oficial |
|---|---|
| Finalidade e navegação do repositório | `README.md` |
| Instruções operacionais para agentes | `AGENTS.md` |
| Estado e registro do bootstrap | `.ai/project-init.md` |
| Problema, contexto e resultados aprovados | `.ai/vision.md` |
| Papéis, autoridade, workflows, DoR e DoD | `.ai/workflow.md` |
| Hierarquia, tipos, estados e regras do backlog | `.ai/backlog.md` |
| Como conversar, interromper e retomar trabalho | `.ai/interaction-guide.md` |
| Segurança, dados, dependências e ações de alto impacto | `.ai/security.md` |
| Política geral de qualidade e implementação | `.ai/engineering.md` |
| Stack, comandos e convenções técnicas locais | `.ai/engineering-context.md` |
| Versão herdada e procedimento de atualização | `.blueprint/` e `.ai/blueprint-updates.md` |
| Trabalho acionável | GitHub Issue |
| Estado, prioridade e visão transversal | GitHub Project |
| Discussão ligada a uma mudança | Issue ou pull request |
| Implementação e revisão | Pull request |
| Decisão estrutural relevante | ADR em `.ai/decisions/` |
| Versão publicada | Tag e GitHub Release |
| Configuração remota reproduzível | `.ai/github-setup.md` e `scripts/configure-github.sh` |
| Modelos textuais reutilizáveis | `.ai/templates/` |
| Auditoria de um derivado descartável | `.ai/template-audit.md` |

Um artefato deve apontar para a fonte oficial, não copiar conteúdo que precise ser mantido em dois lugares.

## Consistência transversal

Uma mudança deve preservar a coerência do assunto em todo o repositório. Antes e depois de alterar comportamento, política, contrato, workflow ou conceito documentado:

1. identificar a fonte oficial;
2. pesquisar referências, nomes antigos, exemplos e automações relacionados;
3. atualizar todos os artefatos afetados na mesma entrega;
4. substituir duplicação por links quando isso reduzir manutenção;
5. registrar no PR o que foi verificado e o que não se aplica;
6. tratar qualquer atualização externa ao escopo como bloqueio explícito ou follow-up, nunca como divergência silenciosa.

“Documentação atualizada” inclui, conforme aplicável, README, instruções de agentes, guias, templates, ADRs, exemplos, comentários normativos, esquemas, configuração, workflows e metadados. Código e testes também devem acompanhar mudanças de comportamento documentado.

## Separação do conteúdo

- **Herdado:** método, regras, templates, scripts genéricos e instruções.
- **Inicialização:** placeholders marcados com `TODO(PROJECT_INIT)`.
- **Local:** visão preenchida, comandos, ADRs, issues, PRs e decisões do projeto derivado.
- **Exemplo:** somente conteúdo marcado `EXAMPLE_ONLY`; deve ser removido no bootstrap.

## Ordem por workflow

- Descoberta: `project-init.md`, `vision.md` e `workflow.md`.
- Planejamento: `vision.md`, `backlog.md` e `workflow.md`.
- Implementação: issue aprovada, `AGENTS.md`, `workflow.md`, `engineering.md`, `engineering-context.md` e ADRs ligados.
- Trabalho sensível: `security.md`, além das fontes do workflow ativo.
- Revisão: issue, PR, critérios de aceite, diff, evidências e DoD.
- Release: política aprovada do projeto, commit validado em `main`, tag e checks.

Para exemplos de pedidos em linguagem natural e regras de retomada, consulte `interaction-guide.md` em qualquer workflow.

## Princípio de evolução

Projetos derivados são independentes. Melhorias desta base devem ser avaliadas e incorporadas por issue e PR locais; nunca são sincronizadas automaticamente.
