# Auditoria do Template Repository

> **Para que serve:** valida o Blueprint de ponta a ponta em um repositório derivado descartável antes de considerá-lo pronto para reutilização.

Execute esta auditoria depois de publicar ou alterar substancialmente a base. O repositório de teste deve ser claramente descartável e nunca conter segredos ou dados reais.

## Cenário

- [ ] Criar um derivado privado pelo Template Repository, sem `--include-all-branches`.
- [ ] Confirmar que `origin` aponta para o derivado.
- [ ] Executar `./scripts/start-project.sh`.
- [ ] Configurar e conferir os workflows nativos do Project.
- [ ] Interromper e retomar o bootstrap para validar idempotência.
- [ ] Confirmar que o bootstrap não aceita `COMPLETE` enquanto `.ai/engineering-context.md` estiver `NOT_STARTED` ou contiver placeholders materiais.
- [ ] Preencher o contexto como `CONFIGURED` ou `NOT_APPLICABLE` com justificativa e confirmar que a validação passa.
- [ ] Executar `scripts/check-blueprint-update.sh` e confirmar a comparação com a release registrada em `.blueprint/version`.
- [ ] Concluir placeholders e abrir draft PR.
- [ ] Confirmar que draft incompleto é aceito pela governança básica.
- [ ] Marcar como pronto com checklist incompleto e confirmar rejeição.
- [ ] Corrigir o PR e confirmar o check `governance`.
- [ ] Integrar o PR e confirmar fechamento da issue e `Done`.
- [ ] Reabrir uma issue e confirmar recuperação para `Refinement`.
- [ ] Fechar um PR sem merge e confirmar que a issue não fica `Done`.
- [ ] Criar uma tag de versão de teste pelo workflow controlado.
- [ ] Confirmar criação do GitHub Release e imutabilidade da tag.
- [ ] Executar `./scripts/doctor.sh` e resolver falhas.
- [ ] Registrar limitações de plano, permissão ou API encontradas.
- [ ] Excluir o repositório descartável somente após confirmar o alvo exato.

## Critério de aprovação

A base está pronta quando o caminho recomendado funciona sem intervenção não documentada, controles rejeitam os casos negativos e o `doctor.sh` não apresenta falhas. Avisos sobre workflows nativos são aceitos somente após verificação visual registrada.
