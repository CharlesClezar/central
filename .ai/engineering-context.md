# Contexto de engenharia do projeto

> **Para que serve:** registra as escolhas concretas de stack, arquitetura, comandos e convenções que a política geral de engenharia não pode definir antecipadamente. Deve ser preenchido no bootstrap do projeto derivado.

```yaml
engineering_configuration:
  status: NOT_STARTED
  approved_by: null
  approved_at: null
```

Estados permitidos: `NOT_STARTED`, `CONFIGURED` e `NOT_APPLICABLE`.

- `CONFIGURED`: o projeto terá implementação técnica e as seções aplicáveis estão preenchidas e aprovadas.
- `NOT_APPLICABLE`: o repositório não terá software executável; exige justificativa explícita abaixo.
- `NOT_STARTED`: bloqueia a conclusão do bootstrap e qualquer implementação de produto ou tecnologia.

## Aplicabilidade

- Justificativa para `NOT_APPLICABLE`: TODO(PROJECT_INIT)

## Stack e execução

- Linguagem e versão: `<PROJECT_LANGUAGE_AND_VERSION>`
- Runtime ou plataforma: `<PROJECT_RUNTIME>`
- Frameworks principais: `<PROJECT_FRAMEWORKS>`
- Gerenciador de dependências: `<PROJECT_PACKAGE_MANAGER>`
- Sistemas externos necessários: `<PROJECT_EXTERNAL_SYSTEMS>`

## Comandos oficiais

- Preparar ambiente: `<PROJECT_SETUP_COMMAND>`
- Executar localmente: `<PROJECT_RUN_COMMAND>`
- Formatar: `<PROJECT_FORMAT_COMMAND>`
- Lint: `<PROJECT_LINT_COMMAND>`
- Análise de tipos ou estática: `<PROJECT_STATIC_ANALYSIS_COMMAND>`
- Testes unitários: `<PROJECT_UNIT_TEST_COMMAND>`
- Testes de integração: `<PROJECT_INTEGRATION_TEST_COMMAND>`
- Testes end-to-end: `<PROJECT_E2E_TEST_COMMAND>`
- Build: `<PROJECT_BUILD_COMMAND>`
- Verificação de segurança: `<PROJECT_SECURITY_COMMAND>`

Use `N/A — <justificativa>` quando um comando realmente não se aplicar. Não deixe campo vazio nem invente comando para satisfazer o checklist.

## Convenções de implementação

- Idioma dos identificadores: `<PROJECT_IDENTIFIER_LANGUAGE>`
- Formatação e estilo: `<PROJECT_STYLE_CONVENTION>`
- Organização de módulos: `<PROJECT_MODULE_ORGANIZATION>`
- Tratamento de erros: `<PROJECT_ERROR_STRATEGY>`
- Logs e observabilidade: `<PROJECT_OBSERVABILITY_STRATEGY>`
- Estratégia de configuração e ambientes: `<PROJECT_CONFIGURATION_STRATEGY>`

## Arquitetura e fronteiras

- Forma arquitetural inicial: `<PROJECT_ARCHITECTURE>`
- Módulos ou contextos principais: `<PROJECT_MODULES>`
- Persistência e migrações: `<PROJECT_PERSISTENCE>`
- APIs, eventos ou contratos: `<PROJECT_CONTRACTS>`
- Decisões delegadas a ADRs: `<PROJECT_ENGINEERING_ADRS>`

## Estratégia de testes

- Pirâmide ou distribuição esperada: `<PROJECT_TEST_STRATEGY>`
- Fronteiras que exigem integração: `<PROJECT_INTEGRATION_BOUNDARIES>`
- Fluxos críticos que exigem E2E: `<PROJECT_CRITICAL_FLOWS>`
- Critério de cobertura quando aplicável: `<PROJECT_COVERAGE_POLICY>`

## Requisitos não funcionais

- Segurança e privacidade: `<PROJECT_SECURITY_REQUIREMENTS>`
- Desempenho e escala esperada: `<PROJECT_PERFORMANCE_EXPECTATIONS>`
- Disponibilidade e recuperação: `<PROJECT_RELIABILITY_EXPECTATIONS>`
- Acessibilidade e dispositivos: `<PROJECT_ACCESSIBILITY_EXPECTATIONS>`
- Compatibilidade suportada: `<PROJECT_COMPATIBILITY_TARGETS>`

## Regra de atualização

Alterações materiais de stack, arquitetura, contratos, dados, comandos oficiais ou requisitos não funcionais atualizam este arquivo e os ADRs aplicáveis na mesma entrega. A IA deve consultar este contexto antes de planejar, implementar, revisar ou recomendar dependências.
