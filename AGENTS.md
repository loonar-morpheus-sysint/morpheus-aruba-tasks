# AGENTS.md

*Guia para Agentes de Código (AI e Humanos) - Automações Aruba/Morpheus*

## Propósito

Este documento orienta agentes de código (inteligência artificial e desenvolvedores humanos) na criação de scripts Bash para automações de redes Aruba integradas ao Morpheus, seguindo padrões estabelecidos de logging centralizado, nomenclatura consistente e boas práticas de desenvolvimento.

**Referência**: Este documento segue os padrões da iniciativa [agents.md](https://agents.md) para documentação direcionada a agentes autônomos.

## Arquitetura e Dependências

### commons.sh - Biblioteca Central

Todos os scripts devem utilizar o arquivo `commons.sh` como base para:

- Sistema de logging padronizado (todos os níveis syslog)
- Funções utilitárias comuns
- Validação de variáveis de ambiente
- Tratamento de erros consistente

### Template Obrigatório de Cabeçalho

**IMPORTANTE**: Todo script deve seguir este template de cabeçalho EXATAMENTE:

```bash
#!/bin/bash
################################################################################
# Script: nome-do-script.sh
# Description: Descrição breve do que o script faz
################################################################################
#
# Descrição detalhada (opcional)
# Pode conter múltiplas linhas explicando o propósito,
# parâmetros, variáveis de ambiente, exemplos, etc.
#
################################################################################

# Carrega biblioteca comum (deve ser a primeira linha funcional)
source "$(dirname "${BASH_SOURCE[0]}")/commons.sh"

# Resto do script...
```

**OBRIGATÓRIO**: As linhas `# Script:` e `# Description:` devem estar presentes EXATAMENTE neste formato. Os testes BATS validam este padrão.

## Convenções de Nomenclatura

### Arquivos

- **OBRIGATÓRIO**: Use hífens (`-`) para separar palavras
- **PADRÃO**: `verbo-substantivo.sh`
- **Exemplos**: `create-vrf.sh`, `install-aruba-cli.sh`, `backup-config.sh`

### Funções

- **PADRÃO**: `verbo_substantivo()` (underscore)
- **Prefixo**: Use prefixo quando necessário (`aruba_authenticate`, `morpheus_deploy`)
- **Exemplos**: `validate_config()`, `aruba_check_auth()`, `create_backup()`

### Variáveis

- **GLOBAIS**: `MAIÚSCULAS_COM_UNDERSCORE`
- **Locais**: `minúsculas_com_underscore`
- **Exemplos**: `ARUBA_HOST`, `CONFIG_PATH`, `backup_file`

**IMPORTANTE - Nomenclatura em Inglês**:

- **OBRIGATÓRIO**: Use sempre nomes de variáveis em português
- **PRIORIDADE**: Legibilidade sobre concisão
- **Exemplos corretos**: `arquivo_configuracao`, `CAMINHO_BACKUP`, `lista_dispositivos`
- **Exemplos incorretos**: `cfg_file`, `BKPATH`, `devlist`

## Padrão de Logging

### Logging Obrigatório em Funções

**REGRA CRÍTICA**: TODAS as funções DEVEM ter logging de entrada e saída. Esta é uma validação obrigatória do BATS.

```bash
minha_funcao() {
  _log_func_enter "minha_funcao"  # ← OBRIGATÓRIO: Primeira linha da função
  local param="$1"

  log_info "Executando operação X"  # Operações importantes

  log_info "Coletando informações do sistema"

  if aoscx "show version" > "system_info.txt"; then
    log_success "Informações coletadas em system_info.txt"
    _log_func_exit_ok "minha_funcao"  # ← OBRIGATÓRIO: Antes de return 0
    return 0
  else
    log_error "Falha na coleta de informações"
    _log_func_exit_fail "minha_funcao" "1"  # ← OBRIGATÓRIO: Antes de return 1
    return 1
  fi
}
```

**IMPORTANTE**:

- `_log_func_enter` deve ser a PRIMEIRA linha de toda função
- `_log_func_exit_ok` deve preceder TODOS os `return 0`
- `_log_func_exit_fail` deve preceder TODOS os `return 1` (ou outros códigos de erro)
- O nome da função deve ser EXATAMENTE o mesmo em enter/exit

## Estrutura Obrigatória de Scripts

### Função main() - OBRIGATÓRIA

**CRÍTICO**: Todo script executável DEVE ter uma função `main()` e proteção contra sourcing:

```bash
main() {
  _log_func_enter "main"

  # Lógica principal do script aqui
  log_info "Iniciando processamento..."

  # Seu código...

  _log_func_exit_ok "main"
  return 0
}

# Proteção: executa main() apenas se script for chamado diretamente (não sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi
```

**POR QUE**: Isso permite que o script seja tanto executável quanto importável (sourced) por outros scripts.

### Validação de Dependências

**OBRIGATÓRIO**: Sempre valide dependências ANTES de usá-las:

```bash
check_command() {
  _log_func_enter "check_command"
  local cmd="$1"

  if command -v "${cmd}" &> /dev/null; then
    log_success "Command '${cmd}' is available"
    _log_func_exit_ok "check_command"
    return 0
  else
    log_error "Command '${cmd}' is not available"
    _log_func_exit_fail "check_command" "1"
    return 1
  fi
}

# Uso:
if ! check_command "python3"; then
  log_error "python3 is required but not installed"
  exit 1
fi
```

**NUNCA** assuma que um comando existe. **SEMPRE** valide com `command -v`.

## Diretrizes para Agentes AI

### Quando Criar Novos Scripts

1. **SEMPRE** use o template de cabeçalho EXATO (Script: / Description:)
2. **SEMPRE** inclua `commons.sh` como primeira linha funcional
3. **SEMPRE** crie função `main()` com proteção contra sourcing
4. **SEMPRE** implemente logging `_log_func_enter` e `_log_func_exit_*` em TODAS as funções
5. **SEMPRE** use nomenclatura com hífens para arquivos
6. **SEMPRE** valide dependências com `command -v` antes de usar
7. **SEMPRE** valide parâmetros e variáveis de ambiente
8. **SEMPRE** use nomes de variáveis em inglês (priorize legibilidade sobre concisão)
9. **SEMPRE** Variáveis globais devem sempre ser em MAIÚSCULA e variáveis locais em minúsculas. Palavras separadas com underscores.

### Checklist de Qualidade (Validação BATS)

**CRÍTICO**: Os seguintes itens são VALIDADOS AUTOMATICAMENTE pelos testes BATS:

#### Estrutura do Script (OBRIGATÓRIO)

- [ ] Cabeçalho contém `# Script: nome-do-script.sh` (formato exato)
- [ ] Cabeçalho contém `# Description: ...` (formato exato)
- [ ] Shebang correto: `#!/bin/bash` ou `#!/usr/bin/env bash`
- [ ] Script usa `source.*commons.sh`
- [ ] Script tem função `main()` implementada. Exceto o commons.sh
- [ ] Nome do arquivo segue padrão kebab-case (`nome-com-hifens.sh`)
- [ ] Script é executável (`chmod +x`)

#### Funções (OBRIGATÓRIO)

- [ ] Função `main()` existe e está implementada
- [ ] TODAS as funções têm `_log_func_enter "nome_funcao"` como primeira linha
- [ ] TODAS as funções têm `_log_func_exit_ok` antes de `return 0`
- [ ] TODAS as funções têm `_log_func_exit_fail` antes de `return 1`
- [ ] Script tem proteção: `if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then main "$@"; fi`

#### Logging e Erros (OBRIGATÓRIO)

- [ ] Script usa funções de log: `log_info`, `log_error`, `log_success`, `log_warning`
- [ ] Script tem tratamento de erros: `return 1` ou `exit 1`
- [ ] Script usa códigos de retorno adequados

#### Validações (OBRIGATÓRIO)

- [ ] Valida variáveis de ambiente necessárias (ex: `ARUBA_HOST`)
- [ ] Valida dependências com `command -v` antes de usar
- [ ] Valida parâmetros obrigatórios

#### Documentação (OBRIGATÓRIO)

- [ ] Comentários descritivos em seções principais
- [ ] Uso consistente dos níveis de log

**DICA**: Execute `./run-tests.sh` para validar automaticamente todos esses itens.

## Validação de Código e Documentação

### Validação Obrigatória de Scripts Shell

**TODOS** os scripts Bash (`.sh`) devem ser validados com **shellcheck** antes de serem submetidos ao repositório. Esta é uma prática obrigatória que garante:

- Detecção de erros sintáticos e semânticos
- Identificação de más práticas e armadilhas comuns
- Conformidade com padrões POSIX quando aplicável
- Código mais robusto e manutenível

#### Como Validar Scripts com shellcheck

**Instalação:**

```bash
# Ubuntu/Debian
sudo apt-get install shellcheck

# macOS
brew install shellcheck

# Fedora
sudo dnf install shellcheck
```

**Exemplo de uso:**

```bash
# Validar um único script
shellcheck meu-script.sh

# Validar todos os scripts do diretório
shellcheck *.sh

# Validar com severidade específica (error, warning, info, style)
shellcheck -S warning meu-script.sh
```

**Exemplo de saída esperada:**

```bash
$ shellcheck create-vrf.sh

In create-vrf.sh line 42:
  if [ $? -eq 0 ]; then
       ^-- SC2181: Check exit code directly with e.g. 'if mycmd;', not indirectly with $?.
```

**IMPORTANTE**: Corrija todos os avisos e erros reportados pelo shellcheck antes de fazer commit. Scripts com avisos críticos não devem ser aceitos no repositório.

### Validação Obrigatória de Arquivos Markdown

**TODOS** os arquivos Markdown (`.md`) devem ser validados com **markdownlint** para assegurar padronização, legibilidade e consistência na documentação. Esta é uma prática obrigatória que garante:

- Formatação consistente em toda a documentação
- Legibilidade melhorada
- Conformidade com padrões de estilo estabelecidos
- Documentação profissional e de fácil manutenção

#### Como Validar Markdown com markdownlint

**Instalação:**

```bash
# Via npm (Node.js necessário)
npm install -g markdownlint-cli

# Via yarn
yarn global add markdownlint-cli
```

**Exemplo de uso:**

```bash
# Validar um arquivo específico
markdownlint README.md

# Validar todos os arquivos Markdown
markdownlint *.md

# Validar e corrigir automaticamente problemas simples
markdownlint --fix AGENTS.md

# Validar com configuração personalizada
markdownlint -c .markdownlint.json *.md
```

**Exemplo de saída esperada:**

```bash
$ markdownlint AGENTS.md

AGENTS.md:15 MD022/blanks-around-headings Headings should be surrounded by blank lines
AGENTS.md:23 MD031/blanks-around-fences Fenced code blocks should be surrounded by blank lines
```

**IMPORTANTE**: Corrija todos os avisos reportados pelo markdownlint antes de fazer commit. A documentação deve seguir padrões consistentes em todo o projeto.

### Integração no Workflow de Desenvolvimento

#### Antes de Fazer Commit

**Para Scripts Bash:**

```bash
# 1. Execute shellcheck
shellcheck seu-script.sh

# 2. Corrija todos os problemas reportados
# 3. Execute novamente até não haver avisos
# 4. Faça o commit
git add seu-script.sh
git commit -m "Add: Novo script validado com shellcheck"
```

**Para Arquivos Markdown:**

```bash
# 1. Execute markdownlint
markdownlint seu-documento.md

# 2. Corrija os problemas ou use --fix para correções automáticas
markdownlint --fix seu-documento.md

# 3. Revise as mudanças
# 4. Faça o commit
git add seu-documento.md
git commit -m "Docs: Atualização validada com markdownlint"
```

#### Automação com Git Hooks (Recomendado)

Considere criar um `.git/hooks/pre-commit` para validação automática:

```bash
#!/bin/bash
# .git/hooks/pre-commit

echo "Executando validações..."

# Valida scripts modificados
for file in $(git diff --cached --name-only --diff-filter=ACM | grep '\.sh$'); do
  echo "Validando $file com shellcheck..."
  shellcheck "$file" || exit 1
done

# Valida arquivos Markdown modificados
for file in $(git diff --cached --name-only --diff-filter=ACM | grep '\.md$'); do
  echo "Validando $file com markdownlint..."
  markdownlint "$file" || exit 1
done

echo "✓ Todas as validações passaram!"
exit 0
```

### Resumo das Boas Práticas de Validação

✅ **OBRIGATÓRIO**: Validar todos os scripts `.sh` com shellcheck
✅ **OBRIGATÓRIO**: Validar todos os arquivos `.md` com markdownlint
✅ **RECOMENDADO**: Usar git hooks para automação
✅ **RECOMENDADO**: Integrar validações no CI/CD pipeline
✅ **BOA PRÁTICA**: Corrigir todos os avisos, não apenas erros
✅ **BOA PRÁTICA**: Executar validações localmente antes do push

## Manutenção de Padrões

### Para Agentes Humanos

- Revisar este documento antes de criar novos scripts
- Usar scripts existentes como referência
- Contribuir com melhorias neste guia

### Para Agentes AI

- Sempre referenciar este documento como base
- Manter consistência com padrões estabelecidos
- Aplicar todas as diretrizes sem exceção
- Priorizar legibilidade e manutenibilidade

## Template Completo de Script

Use este template como base para TODOS os novos scripts:

```bash
#!/bin/bash
################################################################################
# Script: nome-do-script.sh
# Description: Descrição breve do que o script faz
################################################################################
#
# DESCRIÇÃO DETALHADA:
#   Explicação completa do propósito do script
#
# VARIÁVEIS DE AMBIENTE:
#   VARIAVEL_NECESSARIA: Descrição da variável
#
# USO:
#   ./nome-do-script.sh [opcoes]
#
# EXEMPLOS:
#   ./nome-do-script.sh --parametro valor
#
################################################################################

# Carrega biblioteca comum
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/commons.sh"

################################################################################
# Funções
################################################################################

# Função exemplo
exemplo_funcao() {
  _log_func_enter "exemplo_funcao"
  local param="$1"

  # Validação de parâmetro
  if [[ -z "${param}" ]]; then
    log_error "Parâmetro obrigatório não fornecido"
    _log_func_exit_fail "exemplo_funcao" "1"
    return 1
  fi

  log_info "Processando: ${param}"

  # Sua lógica aqui
  if comando_qualquer "${param}"; then
    log_success "Operação bem-sucedida"
    _log_func_exit_ok "exemplo_funcao"
    return 0
  else
    log_error "Operação falhou"
    _log_func_exit_fail "exemplo_funcao" "1"
    return 1
  fi
}

# Validar dependências
check_dependencies() {
  _log_func_enter "check_dependencies"
  local deps=("python3" "pip3" "git")

  for cmd in "${deps[@]}"; do
    if ! command -v "${cmd}" &> /dev/null; then
      log_error "Dependência não encontrada: ${cmd}"
      _log_func_exit_fail "check_dependencies" "1"
      return 1
    fi
    log_info "Dependência OK: ${cmd}"
  done

  _log_func_exit_ok "check_dependencies"
  return 0
}

################################################################################
# Função Main
################################################################################

main() {
  _log_func_enter "main"

  log_section "NOME DO SCRIPT"
  log_info "Iniciando processamento..."

  # Validar dependências
  if ! check_dependencies; then
    log_error "Falha na validação de dependências"
    _log_func_exit_fail "main" "1"
    exit 1
  fi

  # Validar variáveis de ambiente
  if [[ -z "${VARIAVEL_NECESSARIA:-}" ]]; then
    log_error "VARIAVEL_NECESSARIA não definida"
    _log_func_exit_fail "main" "1"
    exit 1
  fi

  # Processar argumentos
  while [[ $# -gt 0 ]]; do
    case $1 in
      --help|-h)
        show_usage
        _log_func_exit_ok "main"
        exit 0
        ;;
      --parametro)
        PARAMETRO="$2"
        shift 2
        ;;
      *)
        log_error "Parâmetro desconhecido: $1"
        show_usage
        _log_func_exit_fail "main" "1"
        exit 1
        ;;
    esac
  done

  # Executar lógica principal
  if exemplo_funcao "${PARAMETRO}"; then
    log_success "Script concluído com sucesso"
    _log_func_exit_ok "main"
    exit 0
  else
    log_error "Script falhou"
    _log_func_exit_fail "main" "1"
    exit 1
  fi
}

# Executar main apenas se script for chamado diretamente
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi
```

## Erros Comuns a Evitar

### ❌ NÃO FAÇA

```bash
# ❌ Cabeçalho sem formato padrão
# nome_script.sh - Descrição

# ❌ Função sem logging
funcao() {
  echo "fazendo algo"
  return 0
}

# ❌ Código solto (sem main)
echo "Iniciando..."
fazer_algo
exit 0

# ❌ Usar comando sem validar
pip3 install pacote  # E se pip3 não existir?

# ❌ Exit/Return sem logging
if erro; then
  return 1  # Falta _log_func_exit_fail
fi
```

### ✅ FAÇA

```bash
# ✅ Cabeçalho padronizado
# Script: nome-script.sh
# Description: O que o script faz

# ✅ Função com logging completo
funcao() {
  _log_func_enter "funcao"
  log_info "Fazendo algo"
  _log_func_exit_ok "funcao"
  return 0
}

# ✅ Código em main()
main() {
  _log_func_enter "main"
  log_info "Iniciando..."
  fazer_algo
  _log_func_exit_ok "main"
  exit 0
}

# ✅ Validar antes de usar
if ! command -v pip3 &> /dev/null; then
  log_error "pip3 não encontrado"
  exit 1
fi
pip3 install pacote

# ✅ Exit/Return com logging
if erro; then
  _log_func_exit_fail "funcao" "1"
  return 1
fi
```

---

**Nota**: Este documento deve ser atualizado conforme novos padrões são estabelecidos no projeto. Mantenha sempre a versão mais recente como referência.

**Última Atualização**: Adicionados templates e checklist detalhado baseado em correções identificadas pelos testes BATS (outubro 2025).
