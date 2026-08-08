# Configuração do GitHub

> **Para que serve:** documenta os recursos remotos que um Template Repository não garante transportar e como reproduzi-los com GitHub CLI em cada projeto derivado.

## Pré-requisitos

- repositório derivado criado e clonado;
- `gh` autenticado com acesso administrativo ao repositório;
- scopes `repo`, `project` e `read:project` quando aplicáveis;
- `jq` disponível para configurar as opções do campo Status;
- Python 3 disponível para a validação local de links Markdown, sem pacotes adicionais;
- remote `origin` apontando para o derivado correto.

## Compatibilidade dos scripts

Os arquivos `scripts/*.sh` usam shell POSIX e são suportados diretamente em:

- macOS;
- Linux;
- runners Ubuntu do GitHub Actions;
- Windows por WSL ou Git Bash, desde que `git`, `gh`, `jq` e `python3` estejam disponíveis nesse mesmo ambiente.

Eles não executam diretamente em `cmd.exe` ou PowerShell sem uma camada POSIX. Os workflows do GitHub não dependem do sistema operacional local porque usam runners Ubuntu.

Python 3 é usado somente pela validação de documentação e não possui dependências de terceiros. Se suporte nativo a PowerShell se tornar necessário, deve-se criar um wrapper `.ps1` ou migrar a orquestração para uma implementação multiplataforma única, mantendo os mesmos contratos e validações.

Confirme a autenticação quando necessário:

```sh
gh auth status
gh auth refresh -s project,read:project
```

## Aplicação inicial

Na raiz do derivado:

```sh
./scripts/configure-github.sh
```

Antes de aplicar, é possível visualizar ou auditar:

```sh
./scripts/configure-github.sh --dry-run
./scripts/configure-github.sh --check
```

`--dry-run` descreve a configuração pretendida sem alterar o GitHub. `--check` lê o estado remoto, compara propriedades, labels, Project, campos e Rulesets e retorna falha quando encontra drift.

Rulesets precisam estar disponíveis para o repositório e o plano da conta. Em contas nas quais esse recurso não é oferecido para repositórios privados, use um repositório público ou um plano GitHub compatível. O configurador interrompe a execução com uma mensagem acionável quando a API de Rulesets não está disponível; ele nunca tenta reutilizar uma resposta de erro como identificador.

O script mostra o repositório e o proprietário identificados pelo `gh`, pede confirmação e então:

1. cria ou atualiza labels estáveis;
2. cria e liga um GitHub Project ao repositório;
3. configura `Status`, `Priority` e `Type`;
4. cria um Ruleset para proteger `main`;
5. protege tags de versão contra alteração e exclusão;
6. imprime o número do Project e as automações nativas que ainda precisam ser habilitadas.

Também padroniza o repositório:

- `main` como branch padrão;
- issues, integração com Projects, auto-merge e atualização de branch habilitados;
- squash e rebase habilitados;
- merge commits desabilitados;
- mensagem de squash baseada em título e descrição do PR;
- branch temporária removida após merge;
- wiki desabilitada inicialmente;
- alertas de vulnerabilidade habilitados quando o plano permitir.

Habilitar auto-merge nessa configuração apenas torna o recurso disponível. Isso não cria uma regra para integrar automaticamente todo PR verde. A solicitação é individual e segue a política de `.ai/workflow.md`:

```sh
gh pr merge <numero> --auto --squash --delete-branch
```

O comando pode integrar imediatamente quando todos os controles já passaram ou deixar a solicitação pendente até os checks terminarem. Falhas continuam bloqueando o merge.

Use `--yes` somente em automação já revisada:

```sh
./scripts/configure-github.sh --yes
```

## Configuração esperada do Project

- Status: Inbox, Refinement, Ready, In Progress, Review, Done.
- Priority: P0, P1, P2, P3.
- Type: Feature, Bug, Technical, Research, Documentation.

O script não prioriza itens e não move issues para `Ready`.

Para não apagar valores existentes, ele só substitui as opções iniciais `Todo`, `In Progress`, `Done` de um Project novo. Se encontrar opções personalizadas, interrompe e pede revisão em vez de sobrescrevê-las.

## Proteção esperada da main

- pull request obrigatório;
- status check `governance` obrigatório;
- conversas resolvidas;
- branch atualizada antes do merge;
- force push e exclusão bloqueados;
- histórico linear;
- zero bypasses configurados pelo script.

Tags `v*` não podem ser alteradas ou excluídas depois da criação.

Checks próprios da stack devem ser adicionados ao Ruleset depois que seus nomes existirem e tiverem executado no repositório. Não torne obrigatório um job que pode ser omitido por filtros, pois isso pode deixar o PR permanentemente pendente.

## Branches e releases

`main` é a única branch permanente. Branches temporárias seguem `AGENTS.md`. O workflow `create-release-tag.yml` cria uma tag `vMAJOR.MINOR.PATCH` manualmente a partir da ponta atual de `main`; `release.yml` valida a origem da tag e cria o GitHub Release.

O projeto pode substituir SemVer somente por decisão local registrada. Publicação de pacote, deploy, migração ou geração de custo deve ser adicionada posteriormente e permanecer sujeita à política de autorização do projeto.

## Entrada das issues no Project

Ligar o Project ao repositório não adiciona retroativamente nem necessariamente adiciona automaticamente todas as issues. Ao criar uma issue via CLI, inclua-a no Project:

```sh
issue_url=$(gh issue view <número> --json url --jq .url)
gh project item-add <project-number> --owner <owner> --url "$issue_url"
```

Para issues abertas manualmente, configure na interface do Project o workflow nativo **Auto-add to project** com o filtro abaixo, substituindo a identificação do repositório:

```text
repo:<owner>/<repo> is:issue
```

O GitHub CLI atualmente cobre criação, ligação, campos e adição de itens, mas não oferece subcomando estável para configurar esse workflow nativo. Uma Action com token de Project é uma alternativa, porém adicionaria segredo e manutenção sem necessidade inicial.

## Workflows nativos recomendados

Na interface do Project, em **Workflows**, configure:

1. **Auto-add to project**: selecione o repositório, use o filtro `is:issue` — ou `repo:<owner>/<repo> is:issue` quando não houver seletor separado —, salve e habilite.
2. **Item added to project**: selecione somente `issue`, defina `Status = Inbox`, salve e habilite.
3. **Item closed**: selecione somente `issue`, defina `Status = Done`, salve e habilite. Issues encerradas como `not planned` não representam entrega e devem ser corrigidas no Project se a automação não permitir distinguir o motivo.
4. **Pull request merged**: desabilitar se PRs não forem adicionados ao Project, evitando cartões duplicados.
5. **Auto-archive**: manter desabilitado inicialmente; habilitar somente quando itens concluídos prejudicarem as visões.

Revise os dois workflows habilitados por padrão em Projects novos, pois o GitHub normalmente configura itens fechados e PRs integrados como `Done` sem conhecer a DoD deste método.

Um ponto verde ao lado do nome indica workflow habilitado. Círculo cinza indica desabilitado. Ícone vermelho em um workflow que deve permanecer desligado significa configuração incompleta ou ausente, não falha de execução. Ao final, devem estar verdes pelo menos **Auto-add to project**, **Item added to project** e **Item closed**. **Auto-add sub-issues to project** pode permanecer habilitado.

Quando estiver assistindo o bootstrap, a IA deve orientar esses passos uma tela por vez, pedir confirmação observável e manter o aviso do diagnóstico até o usuário confirmar os três workflows verdes. Não deve afirmar que a configuração remota está integralmente concluída apenas porque `configure-github.sh` terminou.

Transições com julgamento ou contexto são executadas pela IA com o CLI:

```sh
./scripts/project-item.sh <issue> refinement
./scripts/project-item.sh <issue> ready --approve-ready
./scripts/project-item.sh <issue> in-progress
./scripts/project-item.sh <issue> review
./scripts/project-item.sh <issue> done
```

O helper usa a autenticação interativa do `gh`; nenhum PAT é armazenado no repositório.

## Verificação

Após executar o script:

```sh
gh repo view --web
gh project list --owner "<owner>"
gh api repos/<owner>/<repo>/rulesets
```

Revise também os nomes dos checks na interface do Ruleset após a primeira execução da CI.

Para uma auditoria única local e remota:

```sh
./scripts/doctor.sh
```

O doctor é somente leitura. Ele valida ferramentas, Git, working tree, documentação e configuração remota, mas apresenta aviso para os workflows nativos do Project que ainda exigem inspeção visual.

Antes de considerar a base pronta, execute o cenário descartável de `.ai/template-audit.md`.
