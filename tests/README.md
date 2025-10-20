# Testes BATS

Este diretório contém os testes automatizados para os scripts Shell do projeto usando [BATS (Bash Automated Testing System)](https://github.com/bats-core/bats-core).

## 📊 Estatísticas

- **Total de testes**: 106 testes
- **Arquivos de teste**: 5 arquivos `.bats`
- **Cobertura**: Scripts principais do projeto
- **Performance**: Execução completa ~2-3 minutos
- **Última atualização**: Outubro 2025 (reorganização de estrutura)

## Estrutura

```text
tests/
├── run-tests.sh                    # Script para executar testes (NOVO: movido da raiz)
├── verify-setup.sh                 # Script de verificação de setup (NOVO: movido da raiz)
├── test_helper.bash                # Funções auxiliares para os testes
├── test_aruba-auth.bats            # 10 testes para aruba-auth.sh
├── test_create-vrf.bats            # 13 testes para create-vrf.sh
├── test_create-aruba-vrf.bats      # 50 testes para create-aruba-vrf.sh
├── test_install-aruba-cli.bats     # 14 testes para install-aruba-cli.sh
├── test_setup-github-token.bats    # 19 testes para setup-github-token.sh
└── test_helper/                    # Diretório auxiliar
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

### Verificação Rápida (Recomendado)

```bash
# Verificar configuração completa sem executar todos os testes
./tests/verify-setup.sh

# Saída inclui:
# - Status do BATS instalado
# - Estrutura de diretórios
# - Contagem de testes
# - Validação rápida
```

### Todos os testes (106 testes, ~2-3 minutos)

```bash
# Na raiz do projeto - usando script wrapper
./tests/run-tests.sh

# Ou diretamente com BATS
bats tests/*.bats
```

### Teste específico (⚡ Mais rápido para desenvolvimento)

```bash
# Usando o script wrapper (recomendado)
./tests/run-tests.sh test_aruba-auth.bats

# Executar apenas um arquivo de teste
bats tests/test_aruba-auth.bats

# Executar apenas um teste específico dentro do arquivo
bats -f "Script file exists" tests/test_aruba-auth.bats
```

### Com verbose (para debugging)

```bash
# Verbose com TAP (Test Anything Protocol)
bats -t tests/*.bats

# Verbose apenas de um arquivo
bats -t tests/test_aruba-auth.bats
```

### Performance Tips

⚡ **Durante desenvolvimento**:

```bash
# 1. Verificação rápida (10 segundos)
./tests/verify-setup.sh

# 2. Teste específico (5 segundos)
./tests/run-tests.sh test_aruba-auth.bats

# 3. Suite completa antes de commit (2-3 minutos)
./tests/run-tests.sh
```

📊 **Contagem de testes por arquivo**:

```bash
# Ver quantos testes cada arquivo tem
for file in tests/test_*.bats; do
  echo "$(basename "$file"): $(grep -c '@test' "$file") testes"
done
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
- [ ] Executar todos os testes com `./tests/run-tests.sh`

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

# Exemplo prático:
@test "Verificar saída de comando" {
  run echo "Hello World"
  [ "$status" -eq 0 ]
  [ "$output" = "Hello World" ]
}
```

### Pular teste temporariamente

```bash
@test "teste temporariamente desabilitado" {
  skip "Implementação pendente - Issue #123"
  # código do teste
}
```

### Executar com verbose

```bash
# Verbose com TAP output
bats -t tests/test_aruba-auth.bats

# Apenas mostrar quais testes estão falhando
bats tests/*.bats 2>&1 | grep "not ok"
```

### Troubleshooting

#### Testes muito lentos

**Problema**: Suite completa demora muito.

**Solução**:

```bash
# Execute apenas o arquivo que você modificou
./tests/run-tests.sh test_aruba-auth.bats  # 5 segundos vs 2-3 minutos

# Ou use verify-setup para validação rápida
./tests/verify-setup.sh
```

#### BATS não encontrado

```bash
# Verificar instalação
which bats
bats --version

# Instalar se necessário
sudo apt-get install -y bats  # Ubuntu/Debian
brew install bats-core         # macOS
```

#### Paths incorretos após migração

**Nota**: Em Outubro 2025, `run-tests.sh` e `verify-setup.sh` foram movidos para `tests/`.

```bash
# ❌ Antigo (não funciona mais)
./run-tests.sh

# ✅ Novo (correto)
./tests/run-tests.sh
```

#### Permissões negadas

```bash
# Tornar scripts executáveis
chmod +x tests/run-tests.sh
chmod +x tests/verify-setup.sh

# Verificar
ls -la tests/*.sh
```

## Referências

- [BATS Core Documentation](https://bats-core.readthedocs.io/)
- [BATS Support Library](https://github.com/bats-core/bats-support)
- [BATS Assert Library](https://github.com/bats-core/bats-assert)
- [AGENTS.md - Guia para Agentes](../AGENTS.md)

## Migração para tests/ (Outubro 2025)

### O que mudou

Os scripts de gerenciamento de testes foram reorganizados para melhor estrutura:

**Antes**:

```text
projeto/
├── run-tests.sh          ← raiz
├── verify-setup.sh       ← raiz
└── tests/
    └── test_*.bats
```

**Depois**:

```text
projeto/
└── tests/
    ├── run-tests.sh      ← movido
    ├── verify-setup.sh   ← movido
    └── test_*.bats
```

### Comandos atualizados

| Antes | Depois |
|-------|--------|
| `./run-tests.sh` | `./tests/run-tests.sh` |
| `./verify-setup.sh` | `./tests/verify-setup.sh` |
| `bats tests/*.bats` | `bats tests/*.bats` (sem mudança) |

### Impacto

- ✅ **Documentação**: Toda atualizada
- ✅ **Pre-commit**: Configuração atualizada
- ✅ **GitHub Actions**: Workflows atualizados
- ✅ **Scripts**: Paths internos ajustados
- ✅ **Compatibilidade**: 100% funcional

## Contribuindo

Ao adicionar novos scripts, **sempre** crie os testes correspondentes seguindo os padrões estabelecidos neste diretório.

### Checklist para Novos Scripts

- [ ] Criar `tests/test_<nome-do-script>.bats`
- [ ] Implementar pelo menos 10 testes básicos
- [ ] Testar localmente: `./tests/run-tests.sh test_<nome>.bats`
- [ ] Verificar que passa no pre-commit
- [ ] Documentar testes específicos se necessário

### Padrões de Qualidade

Todo novo script deve ter testes que validam:

1. **Estrutura** (obrigatório):
   - Arquivo existe e é executável
   - Shebang correto
   - Sources `commons.sh`
   - Função `main()` implementada
   - Nomenclatura kebab-case

2. **Logging** (obrigatório):
   - `_log_func_enter` / `_log_func_exit_*`
   - Logs informativos em operações importantes
   - Logs de erro adequados

3. **Validações** (obrigatório):
   - Variáveis de ambiente necessárias
   - Dependências com `command -v`
   - Tratamento de erros

4. **Documentação** (obrigatório):
   - Header com `# Script:` e `# Description:`
   - Comentários em seções complexas
   - Exemplos de uso (se aplicável)
