#!/bin/bash

################################################################################
# aruba_auth.sh - Aruba CLI Authentication Script
################################################################################
# 
# DESCRIÇÃO:
#   Script para autenticar a CLI Aruba (aoscx) usando credenciais de um
#   arquivo .env. Deve ser importado (source) em outros scripts para
#   fornecer autenticação centralizada.
#
# USO DO ARQUIVO .env:
#   Crie um arquivo .env no diretório do projeto com as seguintes variáveis:
#   
#   ARUBA_HOST=192.168.1.1
#   ARUBA_USERNAME=admin
#   ARUBA_PASSWORD=seu_password_seguro
#   ARUBA_API_VERSION=v10.13  # Opcional, padrão: v10.13
#   ARUBA_VERIFY_SSL=false    # Opcional, padrão: false
#
# COMO USAR EM OUTROS SCRIPTS:
#   #!/bin/bash
#   source "$(dirname "$0")/aruba_auth.sh"
#   
#   # A CLI já estará autenticada após o source
#   # Use as funções exportadas:
#   aruba_authenticate  # Re-autentica se necessário
#   aruba_check_auth    # Verifica se está autenticado
#   aruba_logout        # Faz logout da sessão
#
# DEPENDÊNCIAS:
#   - commons.sh (funções de logging)
#   - aoscx CLI instalada
#   - arquivo .env com credenciais
#
################################################################################

# Obtém o diretório do script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Carrega commons.sh para funções de logging
if [ -f "${SCRIPT_DIR}/commons.sh" ]; then
    source "${SCRIPT_DIR}/commons.sh"
else
    echo "ERRO: commons.sh não encontrado em ${SCRIPT_DIR}"
    exit 1
fi

# Carrega variáveis do arquivo .env
ENV_FILE="${SCRIPT_DIR}/.env"

################################################################################
# Função: load_env_file
# Descrição: Carrega variáveis do arquivo .env
################################################################################
load_env_file() {
    log_info "Carregando configurações do arquivo .env"
    
    if [ ! -f "${ENV_FILE}" ]; then
        log_error "Arquivo .env não encontrado: ${ENV_FILE}"
        log_error "Crie um arquivo .env com ARUBA_HOST, ARUBA_USERNAME e ARUBA_PASSWORD"
        return 1
    fi
    
    # Carrega variáveis do .env (ignora linhas vazias e comentários)
    while IFS='=' read -r key value; do
        # Remove espaços em branco e ignora comentários
        key=$(echo "$key" | xargs)
        
        # Ignora linhas vazias e comentários
        [[ -z "$key" || "$key" =~ ^# ]] && continue
        
        # Remove aspas do valor se existirem
        value=$(echo "$value" | sed -e 's/^["\'"'"']//' -e 's/["\'"'"']$//')
        
        # Exporta a variável
        export "$key=$value"
        log_debug "Variável carregada: $key"
    done < "${ENV_FILE}"
    
    log_success "Arquivo .env carregado com sucesso"
    return 0
}

################################################################################
# Função: validate_env_vars
# Descrição: Valida se as variáveis obrigatórias estão definidas
################################################################################
validate_env_vars() {
    log_info "Validando variáveis de ambiente"
    
    local required_vars=("ARUBA_HOST" "ARUBA_USERNAME" "ARUBA_PASSWORD")
    local missing_vars=()
    
    for var in "${required_vars[@]}"; do
        if [ -z "${!var}" ]; then
            missing_vars+=("$var")
            log_error "Variável obrigatória não definida: $var"
        fi
    done
    
    if [ ${#missing_vars[@]} -gt 0 ]; then
        log_error "Variáveis faltando no .env: ${missing_vars[*]}"
        return 1
    fi
    
    log_success "Todas as variáveis obrigatórias estão definidas"
    return 0
}

################################################################################
# Função: aruba_authenticate
# Descrição: Autentica a CLI Aruba com as credenciais do .env
################################################################################
aruba_authenticate() {
    log_info "Iniciando autenticação na CLI Aruba"
    log_info "Host: ${ARUBA_HOST}"
    log_info "Usuário: ${ARUBA_USERNAME}"
    
    # Define valores padrão para variáveis opcionais
    local api_version="${ARUBA_API_VERSION:-v10.13}"
    local verify_ssl="${ARUBA_VERIFY_SSL:-false}"
    
    # Monta o comando de autenticação
    local auth_cmd="aoscx session-login"
    auth_cmd="$auth_cmd -i ${ARUBA_HOST}"
    auth_cmd="$auth_cmd -u ${ARUBA_USERNAME}"
    auth_cmd="$auth_cmd -p ${ARUBA_PASSWORD}"
    auth_cmd="$auth_cmd --api-version ${api_version}"
    
    if [ "${verify_ssl}" = "false" ]; then
        auth_cmd="$auth_cmd --no-verify-ssl"
    fi
    
    log_debug "Executando comando de autenticação"
    
    # Executa o comando e captura o resultado
    if eval "${auth_cmd}" > /dev/null 2>&1; then
        log_success "Autenticação bem-sucedida no switch Aruba CX10000"
        export ARUBA_AUTHENTICATED=true
        export ARUBA_SESSION_HOST="${ARUBA_HOST}"
        return 0
    else
        log_error "Falha na autenticação"
        log_error "Verifique as credenciais no arquivo .env"
        export ARUBA_AUTHENTICATED=false
        return 1
    fi
}

################################################################################
# Função: aruba_check_auth
# Descrição: Verifica se a CLI está autenticada
################################################################################
aruba_check_auth() {
    if [ "${ARUBA_AUTHENTICATED}" = "true" ]; then
        log_info "CLI Aruba autenticada (Host: ${ARUBA_SESSION_HOST})"
        return 0
    else
        log_warning "CLI Aruba não autenticada"
        return 1
    fi
}

################################################################################
# Função: aruba_logout
# Descrição: Faz logout da sessão Aruba
################################################################################
aruba_logout() {
    if [ "${ARUBA_AUTHENTICATED}" != "true" ]; then
        log_warning "Nenhuma sessão ativa para fazer logout"
        return 0
    fi
    
    log_info "Encerrando sessão Aruba"
    
    if aoscx session-logout > /dev/null 2>&1; then
        log_success "Logout bem-sucedido"
        export ARUBA_AUTHENTICATED=false
        export ARUBA_SESSION_HOST=""
        return 0
    else
        log_warning "Falha no logout (a sessão pode já ter expirado)"
        export ARUBA_AUTHENTICATED=false
        export ARUBA_SESSION_HOST=""
        return 1
    fi
}

################################################################################
# Função: aruba_ensure_auth
# Descrição: Garante que há autenticação ativa, re-autenticando se necessário
################################################################################
aruba_ensure_auth() {
    if ! aruba_check_auth > /dev/null 2>&1; then
        log_info "Re-autenticando na CLI Aruba"
        aruba_authenticate
        return $?
    fi
    return 0
}

################################################################################
# INICIALIZAÇÃO AUTOMÁTICA
# Quando este script é importado (source), autentica automaticamente
################################################################################

log_section "ARUBA CLI AUTHENTICATION"

# Carrega o arquivo .env
if ! load_env_file; then
    log_error "Falha ao carregar arquivo .env"
    return 1 2>/dev/null || exit 1
fi

# Valida as variáveis obrigatórias
if ! validate_env_vars; then
    log_error "Variáveis de ambiente inválidas"
    return 1 2>/dev/null || exit 1
fi

# Autentica automaticamente
if ! aruba_authenticate; then
    log_error "Falha na autenticação inicial"
    return 1 2>/dev/null || exit 1
fi

log_section "Autenticação completa - CLI pronta para uso"

# Exporta funções para uso em outros scripts
export -f aruba_authenticate
export -f aruba_check_auth
export -f aruba_logout
export -f aruba_ensure_auth

log_info "Funções exportadas: aruba_authenticate, aruba_check_auth, aruba_logout, aruba_ensure_auth"
