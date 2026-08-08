# Método de trabalho e autoridade

> **Para que serve:** estabelece como pessoas e agentes passam de uma ideia a uma entrega, quem decide cada assunto e quais evidências são necessárias. É política herdada; mudanças materiais exigem aprovação humana.

## Princípios

- GitHub e Markdown versionado são a memória oficial.
- Conversa não é documentação.
- Português é o idioma padrão dos artefatos e comunicações destinados a pessoas. Inglês permanece somente quando exigido ou favorecido por convenção técnica, ferramenta, API, identificador ou arquitetura; mesmo nesses casos, explicações livres devem permanecer em português.
- O usuário controla visão, valor, prioridade, escopo e decisões materiais.
- Hipóteses não são requisitos.
- Descoberta, planejamento, implementação e revisão são atividades distintas.
- Prontidão precede implementação.
- Mudanças são pequenas, verificáveis e ligadas a issues.
- Cada mudança mantém coerentes a fonte oficial e todas as representações relacionadas.
- Reversibilidade amplia autonomia; impacto exige aprovação.
- Ferramentas de IA são substituíveis.
- Burocracia só cresce para resolver problema observado.

## Papéis e handoffs

### Usuário / Product Owner

Decide visão, prioridade, escopo, aceite de produto, arquitetura material, risco relevante, merge e release conforme política. Aprova a passagem para `Ready`.

### Product Strategist

Explora problema, pessoas, evidências, hipóteses, alternativas e riscos. Pode redigir visão; não aprova requisitos, prioridade ou arquitetura. Entrega contexto proposto ao usuário e, após aprovação, ao Product Planner.

### Product Planner

Decompõe contexto aprovado em issues, aceite, limites, dependências e evidências. Avalia DoR; não aprova a própria proposta nem implementa. Entrega issue pronta para decisão do usuário.

### Software Engineer

Implementa uma issue em `Ready`, cria testes e atualiza documentação afetada. Pode tomar decisões técnicas locais e reversíveis; não muda requisito, arquitetura material ou escopo. Entrega PR e evidências ao Reviewer.

### Reviewer

Compara issue, diff e evidências. Procura defeitos, regressões, riscos, escopo excedido e documentação faltante. Não cria requisitos novos nem concede aceite de produto. Recomenda aprovação, mudanças ou bloqueio.

### Architect

Atua excepcionalmente em decisão estrutural, transversal ou difícil de reverter. Compara opções e propõe ADR; o usuário decide.

## Workflows

### Descoberta

- Gatilho: ideia, problema ou necessidade.
- Entrada: relato do usuário e contexto oficial.
- Atividades: perguntas, evidências, hipóteses, alternativas, limites e riscos.
- Aprovação: usuário confirma o contexto e decide prosseguir, pesquisar ou descartar.
- Saída: síntese documentada e decisões ou perguntas explícitas; sem código.

### Planejamento e refinamento

- Gatilho: contexto aprovado suficiente.
- Entrada: documentação oficial e decisão de prosseguir.
- Atividades: objetivo, escopo, fora de escopo, aceite, dependências, riscos e decomposição.
- Aprovação: usuário define prioridade e autoriza `Ready`.
- Saída: issues propostas ou atualizadas e avaliação da DoR; sem implementação.

### Implementação

- Gatilho: issue selecionada e aprovada em `Ready`.
- Entrada: issue, instruções, documentos e dependências satisfeitas.
- Atividades: confirmar entendimento, mapear impacto e referências, inspecionar, planejar, alterar, testar, documentar e repetir a busca de consistência.
- Aprovação: decisão material ausente interrompe apenas o ponto afetado.
- Saída: branch temporária, PR pequeno, evidências, limitações e follow-ups.
- Checkpoint: se o trabalho for interrompido e precisar sobreviver à sessão, publicar os commits na branch remota e manter preferencialmente um draft PR com estado e próximo passo.
- Project: mover para `In Progress` ao iniciar e para `Review` ao abrir o draft PR.

#### Retomada de implementação

Ao receber um pedido como “continue o trabalho”, o Software Engineer deve consultar, nesta ordem:

1. branch atual e seu número de issue;
2. PR aberto ou draft da branch;
3. issue de origem e seus critérios de aceite;
4. item correspondente em `In Progress`;
5. checks, comentários e evidências registrados.

Se houver uma única correspondência coerente, deve resumir o estado e retomar sem exigir que o usuário reconte o contexto. Se houver múltiplas correspondências, fontes conflitantes ou decisão material ausente, deve apresentar a ambiguidade e pedir uma escolha objetiva.

### Revisão

- Gatilho: PR pronto.
- Entrada: issue, aceite, diff, testes e documentos.
- Atividades: verificar escopo, comportamento, regressões, segurança, manutenção e evidências.
- Saída: aprovação recomendada, pedido de mudanças ou bloqueio reproduzível.
- Controle: ideias novas viram follow-up e não são impostas ao PR.
- Project: pedido de alterações que reabre implementação retorna a issue para `In Progress`; aprovação técnica isolada não move para `Done`.

#### Integração e auto-merge

Habilitar auto-merge nas configurações do repositório não integra todo PR verde automaticamente. Cada PR elegível recebe uma solicitação individual:

```sh
gh pr merge <numero> --auto --squash --delete-branch
```

A IA pode solicitá-la somente quando a política previamente aprovada permitir, a issue tiver passado por `Ready`, a entrega estiver completa, não houver decisão ou aceite humano pendente, os riscos estiverem tratados e o Ruleset continuar íntegro. Checks pendentes serão aguardados pelo GitHub; checks com falha bloqueiam a integração e devem ser diagnosticados, nunca contornados.

Depois do merge, a IA confirma o estado remoto, verifica o fechamento da issue, aplica a DoD, move o item para `Done`, sincroniza a `main` local por fast-forward e remove a branch local. Se qualquer condição não estiver satisfeita, mantém o PR aberto e informa o próximo controle necessário.

### Decisão arquitetural

- Gatilho: decisão estrutural material não coberta por orientação vigente.
- Entrada: contexto, restrições, opções e consequências.
- Saída: ADR proposta, decisão humana registrada e itens derivados.
- Controle: implementação dependente aguarda aprovação.

### Release

- Gatilho: decisão de publicar um commit validado de `main`.
- Entrada: SHA em `main`, checks aprovados, versão disponível e política do projeto.
- Atividades: validar origem, criar tag controlada, gerar artefatos e publicar quando autorizado.
- Saída: tag imutável, GitHub Release, evidências e resultado de deploy quando aplicável.
- Controle: merge não cria release automaticamente salvo política local explícita.

### Recuperação do estado operacional

- Issue reaberta: mover de `Done` para `Refinement` e reavaliar DoR.
- PR fechado sem merge: manter issue aberta e retornar de `Review` para `In Progress`, salvo decisão de voltar ao refinamento.
- PR reaberto: mover a issue relacionada para `Review`.
- Check falhou depois de revisão: manter em `Review` se a correção ainda estiver no PR; usar `In Progress` quando nova implementação estiver ativa.
- Item ausente do Project: adicioná-lo e restaurar o status a partir de issue, branch e PR; não inferir prioridade.
- Divergência entre Project e artefatos: issue e PR determinam fatos do trabalho; prioridade e aprovação continuam dependendo do usuário.

## Matriz de autoridade

### Pode executar

- perguntar, analisar e sintetizar sem alterar estado externo;
- criar rascunhos e follow-ups ligados à origem;
- corrigir documentação factual afetada;
- tomar decisão técnica local, segura e reversível;
- refatorar localmente quando necessário ao item;
- criar testes e corrigir bug diretamente necessário aos critérios;
- preparar branch e PR de issue aprovada;
- habilitar merge automático quando a política aprovada e todos os controles forem satisfeitos.

### Pode propor

- visão, requisito, escopo, aceite e prioridade;
- decomposição, tecnologia, arquitetura e dependência;
- refatoração ampla, ADR, exceção, release ou ação externa sem política anterior.

### Somente o usuário decide

- visão, valor, prioridade, roadmap e passagem para `Ready`;
- mudança material de requisito, escopo, arquitetura, segurança, dados ou custo;
- aceitação de risco relevante;
- remoção de funcionalidade ou dados;
- merge, release, deploy ou automação, exceto quando política pré-aprovada já autorizar.

### Nunca pode fazer

- ocultar ambiguidade, falha ou risco conhecido;
- fabricar teste ou evidência;
- transformar hipótese em requisito aprovado;
- expandir escopo ou prioridade silenciosamente;
- expor segredos;
- executar ação destrutiva ou externa sem autorização;
- aprovar PR ou produto em nome do usuário;
- declarar `Done` sem evidência obrigatória.

## Definition of Ready

- [ ] Problema ou resultado desejado está claro.
- [ ] Contexto oficial suficiente está presente ou vinculado.
- [ ] Escopo e fora de escopo estão explícitos.
- [ ] Critérios de aceite são observáveis e verificáveis.
- [ ] Dependências e bloqueios conhecidos foram identificados.
- [ ] Decisões materiais necessárias foram registradas.
- [ ] Não existe conflito conhecido com documento ou ADR vigente.
- [ ] Artefatos e referências potencialmente afetados foram identificados.
- [ ] O item cabe em uma alteração revisável ou foi decomposto.
- [ ] Riscos e validações relevantes foram registrados.
- [ ] Impactos em segurança, dados, permissões, dependências e ações externas foram avaliados.
- [ ] Prioridade e aprovação humana estão claras.
- [ ] Nenhum requisito material precisa ser inventado.
- [ ] Bootstrap está `COMPLETE` e não restam placeholders materiais.
- [ ] Contexto de engenharia está `CONFIGURED`, ou justificadamente `NOT_APPLICABLE` para repositório sem software executável.

Itens não aplicáveis recebem `N/A` com justificativa curta.

## Definition of Done

- [ ] Critérios de aceite atendidos.
- [ ] Alteração dentro do escopo aprovado.
- [ ] Testes relevantes criados ou atualizados e executados.
- [ ] Checks aplicáveis concluídos com resultado registrado.
- [ ] Verificações de segurança aplicáveis foram executadas ou declaradas como não realizadas com justificativa.
- [ ] Código, testes, documentação, exemplos, templates, configuração e automações afetados foram atualizados ou verificados como não aplicáveis.
- [ ] Fonte oficial e representações relacionadas permanecem coerentes e usam links onde isso evita duplicação.
- [ ] Nenhuma decisão durável ficou apenas na conversa ou no código.
- [ ] PR ligado à issue e branch no padrão.
- [ ] Limitações, riscos residuais e verificações ausentes declarados.
- [ ] Achados externos registrados ou propostos separadamente.
- [ ] Revisão concluída e bloqueios resolvidos.
- [ ] Política de merge respeitada.
- [ ] Issue, PR, Project e documentos coerentes.
- [ ] Comunicação humana segue o idioma padrão do projeto, ressalvadas convenções técnicas justificadas.
- [ ] Política de engenharia e contexto específico da stack foram respeitados, com exceções declaradas.

## Controle de consistência transversal

Toda mudança de assunto compartilhado deve seguir este ciclo:

```text
Identificar fonte oficial
  → pesquisar referências e consumidores
  → mapear impacto no plano/PR
  → alterar a fonte e os artefatos afetados
  → repetir a pesquisa
  → testar comportamento e validar links
  → registrar evidências
```

O controle é proporcional: uma busca textual e revisão de links pode bastar para mudança pequena; alteração de contrato público pode exigir código, testes, exemplos, documentação, migração e comunicação. A IA não deve criar arquivos redundantes apenas para demonstrar conformidade.

Quando duas fontes aparentarem ser oficiais para o mesmo dado, interromper a mudança material, escolher uma fonte canônica com aprovação quando necessário e converter a outra em referência ou visão derivada.

## Ambiguidades e exceções

1. Detectar e nomear a lacuna ou conflito.
2. Classificar impacto em produto, arquitetura, segurança, dados, custo, escopo e reversibilidade.
3. Consultar issue, documentos, ADRs e instruções.
4. Decidir localmente ou escalar conforme autoridade.
5. Registrar decisão durável na fonte oficial.

A IA decide somente quando a opção é local, segura, reversível, consistente com padrão vigente e não muda comportamento de produto ou contrato externo. Deve pedir decisão quando houver alternativas materiais, fontes conflitantes, aumento de escopo, ação externa/destrutiva ou impacto em arquitetura, segurança, dados, custo ou dependência.

Ao escalar, apresentar contexto, pergunta objetiva, opções, trade-offs, recomendação e impacto de não decidir.

## Ideias e descobertas durante outro workflow

- Ideia não relacionada: capturar em issue `Inbox`, ligar à origem quando útil, não priorizar e continuar o trabalho atual.
- Detalhe técnico necessário aos critérios: pode ser resolvido dentro do escopo quando local, seguro e reversível.
- Novo requisito: interromper somente a parte afetada e propor atualização ou nova issue antes de implementar.
- Descoberta bloqueante: registrar dependência ou decisão e bloquear apenas o trecho dependente.
- Problema não relacionado: preservar evidência e criar follow-up; não corrigir incidentalmente.

O fluxo é proporcional: captura não obriga refinamento imediato, e uma decisão técnica local não exige ADR. A classificação completa e exemplos estão em `.ai/interaction-guide.md`.
