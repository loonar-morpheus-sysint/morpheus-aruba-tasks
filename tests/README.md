# Testes BATS

Este diretório contém os testes automatizados para os scripts Shell do projeto usando [BATS (Bash Automated Testing System)](https://github.com/bats-core/bats-core).

## Estrutura

```text
tests/
├── test_helper.bash          # Funções auxiliares para os testes
├── test_aruba-auth.bats      # Testes para aruba-auth.sh
├── test_create-vrf.bats      # Testes para create-vrf.sh
└── test_install-aruba-cli.bats # Testes para install-aruba-cli.sh
```

## Instalação do BATS

### Ubuntu/Debian

```bash
sudo apt-get update
sudo apt-get install -y bats
```

### macOS

```bash
brew install bats-core
```

### Outras distribuições

Consulte a [documentação oficial do BATS](https://bats-core.readthedocs.io/en/stable/installation.html).

## Executando os Testes

### Todos os testes

```bash
# Na raiz do projeto
./run-tests.sh

# Ou diretamente com BATS
bats tests/*.bats
```

### Teste específico

```bash
# Executar apenas um arquivo de teste
bats tests/test_aruba-auth.bats

# Ou usando o script helper
./run-tests.sh test_aruba-auth.bats
```

### Com verbose

```bash
bats -t tests/*.bats
```

## Estrutura dos Testes

Cada arquivo de teste segue a seguinte estrutura:

```bash
#!/usr/bin/env bats

load test_helper

setup() {
  # Executado antes de cada teste
  source "${PROJECT_ROOT}/commons.sh"
  setup_mock_env
}

teardown() {
  # Executado após cada teste
  teardown_mock_env
}

@test "Descrição do teste" {
  # Teste propriamente dito
  run comando_a_testar
  [ "$status" -eq 0 ]
}
```

## Tipos de Testes

### Testes de Estrutura

Validam que os scripts seguem os padrões estabelecidos:

- Shebang correto
- Sourcing de `commons.sh`
- Nomenclatura em kebab-case
- Documentação adequada

### Testes de Funcionalidade

Validam comportamento específico:

- Funções existem
- Variáveis de ambiente são validadas
- Logging é implementado
- Tratamento de erros está presente

### Testes de Integração

Validam a interação entre componentes (a implementar):

- Autenticação com Aruba
- Criação de VRF
- Instalação de CLI

## Integração CI/CD

Os testes são executados automaticamente:

### Pre-commit Hook

```bash
# Executado antes de cada commit
pre-commit run bats-tests
```

### GitHub Actions

Os testes são executados em todas as branches no workflow `validation.yml`:

```yaml
- name: Run BATS tests
  run: |
    echo "🧪 Executando testes BATS..."
    bats tests/*.bats
```

## Escrevendo Novos Testes

### Checklist

- [ ] Criar arquivo `test_<nome-do-script>.bats`
- [ ] Adicionar `load test_helper` no início
- [ ] Implementar `setup()` e `teardown()` se necessário
- [ ] Escrever testes descritivos com `@test`
- [ ] Validar localmente com `bats tests/test_<seu-teste>.bats`
- [ ] Executar todos os testes com `./run-tests.sh`

### Exemplo Mínimo

```bash
#!/usr/bin/env bats

load test_helper

@test "meu-script.sh: Script existe e é executável" {
  [ -f "${PROJECT_ROOT}/meu-script.sh" ]
  [ -x "${PROJECT_ROOT}/meu-script.sh" ]
}

@test "meu-script.sh: Script sources commons.sh" {
  run grep -q "source.*commons.sh" "${PROJECT_ROOT}/meu-script.sh"
  [ "$status" -eq 0 ]
}
```

## Funções Auxiliares (test_helper.bash)

### Variáveis

- `PROJECT_ROOT`: Caminho para a raiz do projeto

### Funções Disponíveis

- `setup_mock_env()`: Configura variáveis de ambiente para testes
- `teardown_mock_env()`: Limpa variáveis de ambiente
- `command_exists()`: Verifica se um comando está disponível
- `create_test_dir()`: Cria diretório temporário para testes
- `cleanup_test_dir()`: Remove diretório temporário

## Depuração

### Ver output dos comandos

```bash
# Use 'run' para capturar output
run meu_comando
echo "Status: $status"
echo "Output: $output"
```

### Pular teste temporariamente

```bash
@test "teste temporariamente desabilitado" {
  skip "Implementação pendente"
  # código do teste
}
```

### Executar com verbose

```bash
bats -t tests/test_aruba-auth.bats
```

## Referências

- [BATS Core Documentation](https://bats-core.readthedocs.io/)
- [BATS Support Library](https://github.com/bats-core/bats-support)
- [BATS Assert Library](https://github.com/bats-core/bats-assert)
- [AGENTS.md - Guia para Agentes](../AGENTS.md)

## Contribuindo

Ao adicionar novos scripts, **sempre** crie os testes correspondentes seguindo os padrões estabelecidos neste diretório.
