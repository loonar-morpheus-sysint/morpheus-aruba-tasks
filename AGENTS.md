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

### Exemplo de Inclusão:
```bash
#!/bin/bash
# Script: exemplo-aruba.sh
# Descrição: Script exemplo seguindo padrões estabelecidos

# Carrega biblioteca comum (deve ser a primeira linha após o shebang e comentários)
source "$(dirname "${BASH_SOURCE[0]}")/commons.sh"

# Resto do script...
```

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

## Padrão de Logging

### Logging Obrigatório em Funções
Todas as funções devem implementar logging de entrada, saída e erros:

```bash
minha_funcao() {
  _log_func_enter "minha_funcao"  # Entrada da função
  
  log_info "Executando operação X"  # Operações importantes
  
  if comando_principal; then
    log_success "Operação X concluída com sucesso"
    _log_func_exit_ok "minha_funcao"  # Saída bem-sucedida
    return 0
  else
    rc=$?
    log_error "Falha na operação X (rc=$rc)"
    _log_func_exit_fail "minha_funcao" "$rc"  # Saída com erro
    return $rc
  fi
}
```

### Níveis de Log Disponíveis
- `log_emerg`: Emergência - sistema inutilizável
- `log_crit`: Crítico - falhas que requerem ação imediata
- `log_error`: Erro - condições de erro
- `log_warning`: Aviso - condições de alerta
- `log_notice`: Notificação - condições normais mas significativas
- `log_info`: Informação - mensagens informativas
- `log_debug`: Debug - mensagens de depuração
- `log_success`: Sucesso - operações concluídas com êxito (extensão local)
- `log_section`: Seção - delimitadores de seções principais (extensão local)

## Estrutura Padrão de Scripts

### Template Base
```bash
#!/bin/bash
################################################################################
# Script: nome-do-script.sh
# Descrição: Descrição clara e concisa do propósito
# Autor: [Nome/Sistema]
# Data: [Data de criação]
# Versão: 1.0
################################################################################

# Carrega biblioteca comum
source "$(dirname "${BASH_SOURCE[0]}")/commons.sh"

################################################################################
# VARIÁVEIS GLOBAIS
################################################################################
readonly SCRIPT_NAME="$(basename "$0")"
readonly SCRIPT_VERSION="1.0"

################################################################################
# FUNÇÕES PRINCIPAIS
################################################################################

# Função exemplo
exemplo_funcao() {
  _log_func_enter "exemplo_funcao"
  
  # Validação de parâmetros
  if [[ -z "$1" ]]; then
    log_error "Parâmetro obrigatório não fornecido"
    _log_func_exit_fail "exemplo_funcao" "1"
    return 1
  fi
  
  local parametro="$1"
  log_info "Processando: $parametro"
  
  # Lógica principal
  if operacao_principal "$parametro"; then
    log_success "Operação concluída para: $parametro"
    _log_func_exit_ok "exemplo_funcao"
    return 0
  else
    local rc=$?
    log_error "Falha na operação (rc=$rc)"
    _log_func_exit_fail "exemplo_funcao" "$rc"
    return $rc
  fi
}

################################################################################
# FUNÇÃO PRINCIPAL
################################################################################
main() {
  log_section "INICIANDO $SCRIPT_NAME v$SCRIPT_VERSION"
  
  # Validações iniciais
  if ! validate_env_vars; then
    log_emerg "Variáveis de ambiente inválidas"
    exit 1
  fi
  
  # Lógica principal do script
  if exemplo_funcao "$1"; then
    log_section "$SCRIPT_NAME CONCLUÍDO COM SUCESSO"
    exit 0
  else
    log_section "$SCRIPT_NAME FALHOU"
    exit 1
  fi
}

################################################################################
# EXECUÇÃO PRINCIPAL
################################################################################
# Executa apenas se chamado diretamente (não se for source)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi
```

## Boas Práticas Específicas

### 1. Validação e Tratamento de Erros
```bash
# Sempre valide parâmetros
if [[ $# -lt 1 ]]; then
  log_error "Uso: $0 <parâmetro_obrigatório>"
  exit 1
fi

# Trate códigos de retorno
if ! comando_importante; then
  rc=$?
  log_error "Comando falhou (rc=$rc)"
  exit $rc
fi
```

### 2. Modularização
```bash
# Separe lógica em funções pequenas e específicas
validar_entrada() { ... }
processar_dados() { ... }
gerar_saida() { ... }
```

### 3. Documentação
```bash
################################################################################
# Função: nome_da_funcao
# Descrição: O que a função faz
# Parâmetros:
#   $1 - descrição do primeiro parâmetro
#   $2 - descrição do segundo parâmetro (opcional)
# Retorna:
#   0 - sucesso
#   1 - erro de validação
#   2 - erro de execução
################################################################################
```

### 4. Variáveis de Ambiente
```bash
# Use validação consistente
validate_required_vars() {
  local required_vars=("ARUBA_HOST" "ARUBA_USER" "MORPHEUS_API_KEY")
  
  for var in "${required_vars[@]}"; do
    if [[ -z "${!var}" ]]; then
      log_error "Variável $var não definida"
      return 1
    fi
  done
}
```

## Integração com Aruba CLI

### Padrão de Autenticação
```bash
# Sempre use aruba_ensure_auth antes de operações CLI
if ! aruba_ensure_auth; then
  log_crit "Falha na autenticação Aruba"
  exit 1
fi

# Execute comando com tratamento de erro
if aoscx_command "show version"; then
  log_success "Comando executado com sucesso"
else
  rc=$?
  log_error "Comando falhou (rc=$rc)"
  exit $rc
fi
```

## Scripts de Exemplo

### Script Simples - Coleta de Informações
```bash
#!/bin/bash
# collect-aruba-info.sh
source "$(dirname "${BASH_SOURCE[0]}")/commons.sh"

collect_system_info() {
  _log_func_enter "collect_system_info"
  
  aruba_ensure_auth || { 
    log_crit "Autenticação falhou"
    _log_func_exit_fail "collect_system_info" "1"
    return 1
  }
  
  log_info "Coletando informações do sistema"
  
  if aoscx "show version" > "system_info.txt"; then
    log_success "Informações coletadas em system_info.txt"
    _log_func_exit_ok "collect_system_info"
    return 0
  else
    log_error "Falha na coleta de informações"
    _log_func_exit_fail "collect_system_info" "1"
    return 1
  fi
}
```

## Diretrizes para Agentes AI

### Quando Criar Novos Scripts
1. **SEMPRE** use o template base fornecido
2. **SEMPRE** inclua `commons.sh` como primeira linha funcional
3. **SEMPRE** implemente logging completo em todas as funções
4. **SEMPRE** use nomenclatura com hífens para arquivos
5. **SEMPRE** valide parâmetros e variáveis de ambiente

### Checklist de Qualidade
- [ ] Script usa `commons.sh`
- [ ] Nome do arquivo com hífens
- [ ] Todas as funções têm `_log_func_enter` e `_log_func_exit_*`
- [ ] Tratamento adequado de códigos de retorno
- [ ] Comentários descritivos em seções principais
- [ ] Validação de parâmetros obrigatórios
- [ ] Uso consistente dos níveis de log
- [ ] Função `main()` implementada
- [ ] Proteção contra execução acidental quando sourced

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

---

**Nota**: Este documento deve ser atualizado conforme novos padrões são estabelecidos no projeto. Mantenha sempre a versão mais recente como referência.
