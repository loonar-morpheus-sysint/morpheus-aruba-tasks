# Correção: Instalação do BATS no DevContainer

## Problema Identificado

O BATS (Bash Automated Testing System) não estava sendo instalado durante a criação do devcontainer, causando falhas nos hooks do pre-commit:

```text
BATS Tests...............................................................Failed
- hook id: bats-tests
- exit code: 1

BATS não instalado. Execute sudo apt-get install bats
```

## Solução Implementada

### 1. Atualização do Dockerfile

Adicionado o pacote `bats` na lista de dependências do sistema no arquivo `.devcontainer/Dockerfile`:

```dockerfile
# Instala dependências do sistema
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends \
    build-essential \
    software-properties-common \
    shellcheck \
    shfmt \
    bats \           # ← ADICIONADO
    git \
    curl \
    # ... resto das dependências
```

### 2. Atualização do post-create.sh

Adicionada verificação do BATS no script de pós-criação para confirmar instalação:

```bash
# Bash Development
echo ""
echo "🐚 Ferramentas Bash:"
check_tool "shellcheck" "shellcheck" "--version" || true
check_tool "shfmt" "shfmt" "--version" || true
check_tool "BATS" "bats" "--version" || true        # ← ADICIONADO
check_tool "yamllint" "yamllint" "--version" || true
check_tool "bash-language-server" "bash-language-server" "--version" || true
```

## Verificação

### Versão Instalada

```bash
$ bats --version
Bats 1.10.0
```

### Testes Executados

```bash
$ ./run-tests.sh
🧪 Executando Testes BATS
==================================
37 tests, 0 failures
✅ Todos os testes passaram!
```

### Hook Pre-commit

```bash
$ pre-commit run bats-tests --all-files
BATS Tests...............................................................Passed
```

## Instruções para Usuários Existentes

### Opção 1: Reconstruir o Container (Recomendado)

1. Abra a Command Palette (Ctrl+Shift+P / Cmd+Shift+P)
2. Digite: `Dev Containers: Rebuild Container`
3. Aguarde a reconstrução completa

### Opção 2: Instalação Manual (Temporária)

Se você precisar usar imediatamente sem reconstruir:

```bash
sudo apt-get update && sudo apt-get install -y bats
```

**Nota**: Esta instalação será perdida se o container for recriado. A opção 1 é a solução permanente.

## Arquivos Modificados

- `.devcontainer/Dockerfile` - Adicionado pacote `bats`
- `.devcontainer/post-create.sh` - Adicionada verificação do BATS

## Data da Correção

12 de outubro de 2025

## Status

✅ **CORRIGIDO** - O BATS agora é instalado automaticamente em novos containers
