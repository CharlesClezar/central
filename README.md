# Blueprint para projetos assistidos por IA

> **Para que serve:** este repositório é uma base reutilizável para iniciar projetos pessoais desenvolvidos com assistência de IA. Ele reúne método, governança, templates e validações; não define produto, arquitetura ou stack.

## Estado deste repositório

Este é o **repositório-base**. Ao criar um projeto a partir dele, execute o procedimento em [`.ai/project-init.md`](.ai/project-init.md) antes de implementar funcionalidades.

## Como a base está organizada

- [`.ai/README.md`](.ai/README.md): mapa da metodologia e ordem de leitura.
- [`.ai/workflow.md`](.ai/workflow.md): papéis, workflows, autoridade, Definition of Ready e Definition of Done.
- [`.ai/backlog.md`](.ai/backlog.md): hierarquia, tipos, estados e regras das issues.
- [`.ai/interaction-guide.md`](.ai/interaction-guide.md): exemplos práticos para conversar com a IA, interromper e retomar trabalho.
- [`.ai/security.md`](.ai/security.md): segurança, segredos, conteúdo externo, dependências e ações de alto impacto.
- [`.ai/engineering.md`](.ai/engineering.md): política geral de qualidade, arquitetura, implementação, testes e revisão.
- [`.ai/engineering-context.md`](.ai/engineering-context.md): stack, comandos e convenções que cada derivado deve preencher.
- [`.ai/vision.md`](.ai/vision.md): contexto específico a ser preenchido em cada projeto derivado.
- [`.ai/project-init.md`](.ai/project-init.md): estado e checklist do bootstrap.
- [`AGENTS.md`](AGENTS.md): instruções operacionais descobertas pelo Codex e por agentes compatíveis.
- [`CLAUDE.md`](CLAUDE.md): ponto de entrada do Claude Code.
- [`.github/`](.github): templates e automações nativas do GitHub.
- [`scripts/`](scripts): validações locais e configuração assistida pelo GitHub CLI.

## Regras fundamentais

1. GitHub e arquivos versionados são a fonte oficial; conversas são temporárias.
2. Toda alteração posterior à geração do template deve ter uma issue de origem.
3. Toda alteração deve ocorrer em branch temporária e chegar à `main` por pull request.
4. O PR deve referenciar a issue e apresentar evidências verificáveis.
5. Apenas uma issue aprovada em `Ready` pode ser implementada por vez.
6. Releases são produzidas de forma controlada a partir de tags; merge não implica publicação automática.

Auto-merge fica disponível, mas precisa ser solicitado individualmente para cada PR elegível. A IA só faz isso quando a política aprovada autorizar e todos os controles aplicáveis estiverem satisfeitos; check verde isolado não concede autorização. Consulte [`.ai/workflow.md`](.ai/workflow.md#integração-e-auto-merge).

## Iniciar um projeto de ponta a ponta

Este é o caminho recomendado desde a criação do repositório até a primeira versão. Execute as etapas na ordem. Quando uma política exigir decisão humana, a IA deve apresentar opções e aguardar sua aprovação em vez de inventar uma resposta.

### 1. Preparar o ambiente

Tenha disponível:

- Git;
- [GitHub CLI](https://cli.github.com/) autenticado com `gh auth login`;
- `jq`;
- Python 3;
- shell POSIX: macOS, Linux, WSL ou Git Bash.

Confirme:

```sh
git --version
gh auth status
jq --version
python3 --version
```

Para criar e configurar GitHub Projects, o token do `gh` precisa dos escopos correspondentes:

```sh
gh auth refresh -s project,read:project
```

Rulesets para repositórios privados dependem do plano GitHub. Em conta sem suporte, crie o derivado como público ou use um plano compatível; o configurador interrompe com orientação em vez de aplicar proteção incompleta.

### 2. Criar e clonar o derivado

Não clone o Blueprint diretamente. Gere um repositório independente pelo template:

```sh
gh repo create SEU_USUARIO/NOVO_PROJETO \
  --template SEU_USUARIO/blueprint \
  --private \
  --clone

cd NOVO_PROJETO
```

Use `--public` em vez de `--private` quando apropriado. Não use `--include-all-branches`.

Confirme que o remote aponta para o novo projeto, nunca para o Blueprint:

```sh
git remote -v
```

### 3. Executar o assistente de bootstrap

Na raiz do projeto derivado:

```sh
./scripts/start-project.sh
```

Ele pede confirmação antes de alterar o GitHub e executa, na ordem:

1. confirma que o `origin` é o novo repositório, não a base;
2. verifica autenticação e pré-requisitos;
3. cria labels, Project, campos e Rulesets;
4. cria a issue de bootstrap;
5. coloca a issue em `Refinement`;
6. solicita sua aprovação explícita da DoR do bootstrap;
7. move para `Ready` e `In Progress` somente após a aprovação;
8. cria `bootstrap/<issue>-inicializar-projeto` a partir de `main`;
9. marca o bootstrap como `IN_PROGRESS`.

O script não inventa nome, problema, requisitos, stack ou arquitetura. A IA deve preencher `.ai/engineering-context.md` durante o bootstrap somente com decisões aprovadas pelo usuário e usar `N/A — <justificativa>` no que realmente não se aplicar. O script também não faz commit, push, PR, merge, release ou deploy.

### 4. Configurar os workflows manuais do Project

GitHub Template Repository e GitHub CLI não transportam/configuram integralmente os workflows nativos do Project. Abra o Project criado em **Project → Workflows** e configure:

1. **Auto-add to project**: selecione o novo repositório, use `is:issue`, salve e habilite;
2. **Item added to project**: somente `issue`, `Status = Inbox`, salve e habilite;
3. **Item closed**: somente `issue`, `Status = Done`, salve e habilite;
4. mantenha **Pull request merged** desabilitado quando PRs não forem cartões do Project.

Ao final, **Auto-add to project**, **Item added to project** e **Item closed** devem apresentar ponto verde. **Auto-add sub-issues to project** pode permanecer habilitado. Ícone vermelho em workflow que deve permanecer desligado indica ausência de configuração, não falha de execução.

A IA deve conduzir essa parte uma tela por vez e solicitar confirmação observável. Detalhes e variações da interface estão em [`.ai/github-setup.md`](.ai/github-setup.md#workflows-nativos-recomendados).

### 5. Entregar o bootstrap à IA

Abra sua ferramenta de IA na raiz do derivado e peça:

> Conduza a inicialização da issue indicada pelo script. Leia `AGENTS.md`, `.ai/project-init.md`, `.ai/engineering.md` e `.ai/engineering-context.md`; faça as perguntas mínimas, preencha o contexto técnico apenas com decisões que eu aprovar, atualize todos os artefatos afetados e prepare um draft PR. Não escolha stack, arquitetura ou requisitos sem minha aprovação.

A IA deverá:

1. ler as instruções obrigatórias;
2. confirmar a issue e a branch de bootstrap;
3. conduzir a descoberta mínima;
4. preencher `.ai/vision.md` separando fatos, hipóteses e decisões;
5. preencher `.ai/engineering-context.md` como `CONFIGURED` ou, para repositório sem software executável, `NOT_APPLICABLE` com justificativa;
6. registrar apenas stack, arquitetura, comandos e requisitos não funcionais aprovados;
7. executar as validações aplicáveis;
8. publicar um checkpoint e abrir draft PR;
9. remover placeholders materiais e registrar issue, PR, data e responsável;
10. alterar `.ai/project-init.md` para `COMPLETE` no último commit do bootstrap;
11. preparar o PR para revisão.

O procedimento canônico está em [`.ai/project-init.md`](.ai/project-init.md); exemplos de conversa e retomada estão em [`.ai/interaction-guide.md`](.ai/interaction-guide.md).

### 6. Revisar e integrar o bootstrap

Antes de integrar, confirme:

- `.ai/project-init.md` está `COMPLETE`;
- `.ai/vision.md` foi aprovado;
- `.ai/engineering-context.md` foi aprovado e não possui placeholders;
- checks do PR passaram;
- limitações e decisões pendentes estão declaradas;
- workflows manuais do Project foram confirmados.

Quando a política aprovada autorizar, peça à IA para solicitar auto-merge. O comando operacional é:

```sh
gh pr merge <numero-do-pr> --auto --squash --delete-branch
```

Auto-merge habilitado no repositório não significa que todo PR verde será integrado. A solicitação é individual, e o GitHub aguarda os controles do Ruleset. Depois do merge, a IA deve confirmar issue concluída, item em `Done`, branch remota removida e `main` local sincronizada.

### 7. Confirmar que o projeto está pronto

Na `main` atualizada:

```sh
git switch main
git pull --ff-only
./scripts/doctor.sh
```

O projeto está pronto para implementação quando:

- bootstrap está `COMPLETE`;
- contexto de engenharia está `CONFIGURED`, salvo projeto justificadamente sem software executável;
- configuração local e remota não possui falhas;
- backlog inicial pode ser criado sem inventar requisitos;
- não existe decisão material bloqueante para o próximo item.

Aviso sobre workflows nativos do Project permanece esperado porque o CLI não consegue auditá-los; use a confirmação visual feita na etapa 4.

### 8. Criar e refinar a primeira entrega

Você pode iniciar por uma ideia:

> Quero planejar a primeira entrega: [...]. Atue como Product Strategist, consulte a visão e não implemente ainda.

Depois da descoberta, peça o refinamento:

> Transforme o contexto aprovado em uma issue pequena e verificável. Proponha escopo, fora de escopo, critérios de aceite, riscos e dependências. Não implemente antes da minha aprovação para `Ready`.

A issue deve passar por `Inbox → Refinement → Ready`. A IA não aprova a própria proposta nem define prioridade em seu nome.

### 9. Implementar a primeira issue

Após aprová-la em `Ready`:

> Implemente a issue #<numero>. Leia as políticas e o contexto de engenharia, limite-se ao escopo, execute as verificações aplicáveis, atualize tudo que for afetado e prepare o PR.

A IA deverá:

1. atualizar `main` e criar `feature/<issue>-<slug>`, `bugfix/...`, `technical/...` ou outro tipo permitido;
2. mover a issue para `In Progress`;
3. implementar, testar e documentar;
4. abrir o PR referenciando a issue e movê-la para `Review`;
5. registrar evidências, segurança, engenharia, limitações e impacto transversal;
6. solicitar auto-merge somente quando autorizado;
7. após a integração, concluir issue, Project e limpeza local.

O fluxo detalhado está em [`.ai/workflow.md`](.ai/workflow.md) e as práticas técnicas em [`.ai/engineering.md`](.ai/engineering.md).

### 10. Interromper ou retomar em outra conversa

Para parar com segurança:

> Publique um checkpoint da issue #<numero>, atualize o draft PR com concluído, pendente, verificações e próximo passo, e pare sem ampliar o escopo.

Para retomar:

> Continue o trabalho atual. Inspecione branch, issue, Project, PR e checks antes de alterar qualquer coisa.

Se houver uma única correspondência coerente, a IA retoma sem exigir que você reconte o contexto. Se houver ambiguidade, apresenta as opções. Consulte [`.ai/interaction-guide.md`](.ai/interaction-guide.md#retomar-em-outra-conversa).

### 11. Criar a primeira versão

Depois que a ponta de `main` estiver validada e você autorizar a versão, dispare o workflow controlado com SemVer:

```sh
gh workflow run create-release-tag.yml \
  --ref main \
  -f version=v0.1.0
```

Acompanhe:

```sh
gh run list --workflow create-release-tag.yml --limit 1
gh run list --workflow release.yml --limit 1
gh release view v0.1.0
```

O primeiro workflow cria uma tag imutável na ponta de `main`; o segundo confirma que ela pertence à `main` e cria o GitHub Release. Deploy, publicação de pacote, migração e custos externos exigem política específica e não são autorizados apenas pela criação da tag.

### 12. Diagnosticar e recuperar

Em caso de interrupção, configuração parcial ou dúvida, não reinicie cegamente:

```sh
./scripts/doctor.sh
```

O diagnóstico é somente leitura. `start-project.sh` reutiliza bootstrap em andamento; a IA deve reconstruir o estado a partir de issue, branch, PR, checks e Project.

Problemas encontrados durante o piloto devem virar issues do projeto afetado. Melhorias genéricas do método podem ser propostas separadamente no Blueprint, pois derivados não recebem atualizações automáticas.

### 13. Verificar atualização do Blueprint sob demanda

Quando quiser verificar melhorias posteriores do template, peça:

> Verifique se este projeto está usando a versão mais recente do Blueprint. Se houver atualização, apresente versão, mudanças, riscos e arquivos afetados; não aplique nada antes da minha autorização.

A IA executará:

```sh
./scripts/check-blueprint-update.sh
```

O comando apenas compara `.blueprint/version` com a release mais recente de `.blueprint/source`. Não modifica arquivos, não cria issue e não aplica atualização. Se você autorizar, a IA seguirá [`.ai/blueprint-updates.md`](.ai/blueprint-updates.md): issue, `Ready`, branch, integração cuidadosa conforme o manifesto, validações e PR.

Não há verificação agendada. Projetos derivados são independentes e atualizações nunca são copiadas ou mescladas automaticamente.

## Validar o próprio Blueprint

Antes de publicar uma nova versão do Blueprint, valide um derivado descartável com [`.ai/template-audit.md`](.ai/template-audit.md).

Os scripts `.sh` suportam macOS, Linux, GitHub Actions em Ubuntu e Windows por WSL/Git Bash. Consulte [`.ai/github-setup.md`](.ai/github-setup.md) para pré-requisitos e limitações de portabilidade.
