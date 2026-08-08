# Backlog e GitHub Project

> **Para que serve:** define como ideias viram trabalho rastreável sem criar uma hierarquia ágil desnecessária. Product Planner propõe itens; o usuário aprova prioridade e passagem para `Ready`.

## Hierarquia mínima

1. **Outcome/Épico**, opcional: resultado amplo que realmente requer várias entregas.
2. **Issue implementável:** menor unidade aprovada capaz de produzir uma mudança revisável.

Não criar iniciativa, feature, story e task como níveis simultâneos sem diferença operacional objetiva. `Type` classifica a natureza; não define hierarquia.

## Tipos

- `Feature`: comportamento ou capacidade nova.
- `Bug`: correção de comportamento incorreto.
- `Technical`: manutenção ou melhoria interna verificável.
- `Research`: investigação com pergunta, limite e saída.
- `Documentation`: documentação como resultado principal.

## Estados do Project

| Status | Significado |
|---|---|
| Inbox | Capturado; ainda não aprovado nem refinado |
| Refinement | Em esclarecimento ou decomposição |
| Ready | DoR satisfeita e aprovação humana registrada |
| In Progress | Implementação ativa |
| Review | PR em revisão ou validação |
| Done | DoD satisfeita |

Itens rejeitados são fechados como `not planned` ou arquivados com motivo; não entram em `Done`.

## Campos iniciais

- `Status`: obrigatório.
- `Priority`: `P0`, `P1`, `P2` ou `P3`; decisão do usuário.
- `Type`: um dos tipos acima.
- `Size`: adiar até existir uso; então usar `S`, `M`, `L`.
- `Parent`: relação nativa somente quando existir Outcome/Épico.

Use campos para ordenar e visualizar, relações para hierarquia, labels para classificação estável e texto da issue para contexto. Não duplique manualmente estado ou prioridade no corpo da issue.

## Regras de criação e decomposição

- A IA pode criar follow-ups úteis durante a conversa, sempre ligados à origem.
- A IA não define prioridade nem move a própria proposta para `Ready`.
- A criação automática deve parar se estiver inflando o backlog com hipóteses não aprovadas.
- Cada issue implementável deve ter resultado observável, escopo, fora de escopo, aceite verificável, dependências e evidência esperada.
- Objetivos independentes devem ser separados.
- Descobertas fora do escopo viram follow-up, não expansão incidental.

## WIP

- Uma issue `In Progress` por executor.
- Antes de iniciar outra implementação, resolver revisão bloqueante que o mesmo executor possa tratar.
- Outros limites só são adicionados após congestionamento observado.

## Sincronização operacional

O Project usa automação híbrida:

- workflows nativos adicionam issues e tratam eventos mecânicos configurados;
- a IA usa `scripts/project-item.sh` durante descoberta, planejamento, implementação e revisão;
- `Ready` continua exigindo aprovação humana explícita;
- `Done` exige issue concluída por PR integrado e DoD satisfeita.

Transições normais:

```text
Nova issue → Inbox → Refinement → Ready → In Progress → Review → Done
                                               ↑          │
                                               └──────────┘ alterações solicitadas
```

Issue reaberta retorna para `Refinement`. PR fechado sem merge não produz `Done`. Itens `not planned` são fechados ou arquivados com motivo e permanecem fora do fluxo de entregas concluídas.
