# Guia de interação com assistentes de IA

> **Para que serve:** oferece a pessoas e agentes uma linguagem prática para iniciar, interromper e retomar os workflows do projeto sem depender da memória de uma conversa ou de uma ferramenta específica.

Este guia não cria permissões novas. `workflow.md`, `backlog.md`, a issue e as decisões vigentes continuam sendo as fontes oficiais.

Salvo solicitação explícita em contrário ou exigência técnica, o agente conduz a conversa e redige documentação, issues, PRs, commits e relatórios em português. Termos oficiais de ferramentas podem ser mantidos no idioma original e explicados em português.

## Princípio de continuidade

Uma conversa pode terminar a qualquer momento. Para que outra sessão ou ferramenta continue corretamente, o estado durável deve estar no repositório e no GitHub:

```text
Issue em In Progress
  → branch remota ligada à issue
  → commits existentes
  → draft PR preferencial
  → checks e comentários
  → estado, pendências e próximo passo registrados
```

Alterações apenas locais podem ser retomadas no mesmo workspace, mas não são um checkpoint confiável entre máquinas ou agentes.

## Iniciar descoberta

Pedido possível:

> Tenho esta ideia: [...]. Atue como Product Strategist, consulte o contexto existente e conduza a descoberta sem inventar requisitos.

O agente deve explorar problema, contexto afetado, resultado, evidências, hipóteses, limites e perguntas. Não deve criar item `Ready` nem código.

## Capturar uma ideia sem aprofundar agora

Pedido possível:

> Capture esta ideia no Inbox, ligada ao contexto de origem, mas não a refine nem interrompa o trabalho atual: [...].

O agente pode fazer perguntas mínimas para evitar um registro inútil, criar a issue e retornar ao workflow anterior. Não define prioridade nem aprovação.

## Refinar uma ideia ou issue

Pedido possível:

> Refine a issue #42 como Product Planner. Verifique o contexto oficial, proponha escopo, fora de escopo, critérios de aceite, riscos e dependências, e avalie a DoR. Não implemente.

O usuário revisa a proposta, define prioridade e decide a passagem para `Ready`.

## Escolher o próximo trabalho

Pedidos possíveis:

> Mostre as issues em Ready e recomende a próxima considerando prioridade, bloqueios e tamanho. Não inicie ainda.

> Implemente a issue #42.

> Pode implementar a issue que você recomendou.

O agente só começa após uma seleção humana inequívoca. Se a issue não estiver `Ready`, informa o que falta na DoR em vez de implementar.

## Implementar uma issue

Pedido possível:

> Implemente a issue #42. Trabalhe apenas no escopo aprovado, registre descobertas externas como follow-ups e abra um draft PR assim que houver um checkpoint útil.

O Software Engineer deve:

1. confirmar bootstrap, contexto de engenharia, issue, status e dependências;
2. identificar a fonte oficial e pesquisar referências ou consumidores do assunto;
3. criar `tipo/42-slug` a partir de `main` atualizada;
4. implementar uma unidade revisável;
5. testar e atualizar todos os artefatos afetados;
6. repetir a busca para detectar referências divergentes;
7. publicar a branch e criar ou atualizar o PR;
8. registrar análise de impacto, limitações e follow-ups sem expandir escopo.

Durante o processo, deve manter a issue coerente no Project usando `scripts/project-item.sh`: `In Progress` quando implementar e `Review` quando o draft PR for aberto.

## Interromper ao final de uma sessão

Pedido possível:

> Pare em um estado seguro. Publique o checkpoint da issue #42 e deixe o draft PR preparado para outra sessão continuar.

Antes de encerrar, o agente deve atualizar o PR com uma seção equivalente a:

```markdown
## Estado da implementação

### Concluído
- <resultado já implementado>

### Pendente
- <critério ou trabalho restante>

### Verificações
- <comando ou verificação>: <resultado>
- Não executada: <verificação e motivo>

### Limitações e decisões pendentes
- <item ou “Nenhuma conhecida”>

### Próximo passo
- <ação concreta para retomada>
```

Não transformar isso em diário. Registrar apenas informação necessária para decisão, revisão ou retomada.

## Retomar em outra conversa

Pedidos possíveis:

> Continue a implementação da issue #42. Inspecione a issue, a branch e o draft PR antes de alterar qualquer coisa.

> Continue o draft PR #51 e resolva os checks que falharam, sem ampliar o escopo.

> Continue o trabalho atual.

Para o pedido genérico, o agente procura branch atual, número da issue, PR aberto e item em `In Progress`. Se existir uma correspondência inequívoca, resume concluído, pendente, checks e próximo passo e então continua. Havendo mais de uma possibilidade, pede que o usuário selecione o alvo.

Não é necessário repetir descoberta ou refinamento quando o contexto aprovado continua válido.

Se a retomada detectar Project divergente da issue, branch ou PR, o agente deve corrigir o estado mecânico sem alterar prioridade ou aprovação. Issue reaberta volta para `Refinement`; PR fechado sem merge não conclui trabalho.

## Implementar apenas parte de uma issue

Pedido possível:

> Na issue #42, avalie se os critérios 1 e 2 formam uma entrega independente. Se formarem, proponha a decomposição antes de implementar.

Se a parte produzir incremento independente e revisável, o Product Planner pode propor divisão. Se for apenas etapa interna, o trabalho pode permanecer na mesma issue, mas ela não é declarada `Done` até cumprir todos os critérios aplicáveis.

## Tratar uma nova ideia durante implementação

O agente classifica antes de agir.

### Não relacionada

Criar follow-up em `Inbox`, ligar à origem quando útil e continuar a issue atual.

### Necessária aos critérios existentes

Resolver dentro da issue somente quando for detalhe local, seguro, reversível e necessário ao aceite já aprovado.

### Novo requisito ou expansão de escopo

Parar a parte afetada e apresentar:

- o que a issue autoriza atualmente;
- o comportamento novo;
- impacto em escopo, aceite e implementação;
- recomendação de alterar a issue ou criar outra.

O usuário decide se amplia, substitui, separa, adia ou descarta.

### Descoberta bloqueante

Registrar a dependência ou decisão, bloquear somente o trecho afetado e continuar trabalho independente quando ele ainda formar uma alteração coerente.

### Problema não relacionado encontrado pelo agente

Preservar evidência, criar ou propor follow-up e não corrigir incidentalmente.

## Solicitar revisão

Pedido possível:

> Revise o PR #51 como Reviewer. Compare-o com a issue #42, os critérios de aceite, o diff e as evidências. Não introduza requisitos novos.

O Reviewer usa `.ai/templates/review-report.md` e separa achados bloqueantes de sugestões opcionais.

## Solicitar auto-merge

Pedidos possíveis:

> Quando o PR #51 estiver completo e todos os controles da política forem satisfeitos, solicite auto-merge por squash, acompanhe os checks e conclua a issue e o Project depois da integração.

> Prepare o PR #51, mas não solicite merge; quero revisar e decidir manualmente.

No primeiro caso, a IA não precisa pedir nova confirmação quando a política previamente aprovada já autorizar a integração e não houver decisão material pendente. Ela executa:

```sh
gh pr merge 51 --auto --squash --delete-branch
```

O GitHub integra somente quando os requisitos do Ruleset forem satisfeitos. Se um check falhar, a IA diagnostica a causa, mantém a issue em estado coerente e não enfraquece o controle. No segundo caso, entrega o PR e aguarda o usuário.

Após integração confirmada, a IA verifica issue fechada como concluída, DoD satisfeita, item em `Done`, remoção da branch remota e sincronização da `main` local. “Auto-merge habilitado” e “auto-merge solicitado para este PR” são estados diferentes e devem ser comunicados explicitamente.

## Preparar e publicar versão

Pedidos possíveis:

> Avalie se a ponta de main está pronta para a próxima versão e recomende o incremento. Não crie tag.

> Crie a versão v1.2.0 conforme a política aprovada.

O primeiro pedido é somente análise. O segundo autoriza o workflow controlado de tag, mas publicação, deploy, migração ou custo continuam limitados pela política específica do projeto.

## Pedidos que não devem ser aceitos literalmente

- “Implemente esta ideia” quando ela ainda não tem issue pronta.
- “Aprove sua própria proposta” quando aprovação pertence ao usuário.
- “Aproveite e corrija tudo que encontrar” porque permite expansão silenciosa.
- “Marque como concluído” quando faltam evidências obrigatórias.
- “Faça o deploy” sem política ou autorização aplicável.

Nesses casos, o agente deve explicar o controle necessário e conduzir o próximo passo válido, sem transformar o processo em obstáculo desnecessário.

## Etapas manuais em ferramentas externas

Quando uma configuração necessária não puder ser concluída por CLI, API ou integração disponível, o agente deve:

1. explicar por que a etapa é manual e qual efeito ela produz;
2. fornecer o caminho exato na interface e os valores a selecionar;
3. conduzir uma etapa por vez quando a interface puder variar;
4. solicitar confirmação ou captura da tela para validar sinais observáveis;
5. não declarar a configuração concluída antes da confirmação;
6. registrar o procedimento na documentação oficial para que outra sessão consiga repeti-lo.

Ícones de alerta em workflows desabilitados não são, por si só, falhas. O agente deve distinguir claramente estado desabilitado, configuração incompleta e erro de execução.
