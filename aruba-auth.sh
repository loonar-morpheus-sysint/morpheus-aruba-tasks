#!/bin/bash
################################################################################
# Script: aruba-auth.sh
# Description: Aruba CLI Authentication Script
################################################################################
#
# DESCRIÇÃO:
#   Script para autenticar a CLI Aruba (aoscx) usando credenciais de um
#   arquivo .env. Deve ser importado (source) em outros scripts para
#   fornecer autenticação centralizada.
#
# VARIÁVEIS DE AMBIENTE (.env):
#
#   ARUBA_HOST (obrigatória):
#     Hostname ou endereço IP do controlador/switch Aruba.
#     Exemplo: aruba-controller.example.com ou 192.168.1.100
#
#   ARUBA_USERNAME (obrigatória):
#     Nome de usuário para autenticação no dispositivo Aruba.
#     Deve ter permissões adequadas para executar comandos na CLI.
#
#   ARUBA_PASSWORD (obrigatória):
#     Senha do usuário para autenticação no dispositivo Aruba.
#     Mantenha o arquivo .env seguro e não o commit no repositório.
#
#   ARUBA_PORT (opcional):
#     Porta customizada para conexão com o dispositivo Aruba.
#     Padrão: 443 para HTTPS, 80 para HTTP.
#     Exemplo: 8443 para portas não-padrão.
#     Se não definida, usa a porta padrão do protocolo.
#
#   ARUBA_SSL_VERIFY (opcional):
#     Controla a verificação do certificado SSL/TLS.
#     Valores aceitos: true, false, yes, no, 1, 0
#     Padrão: true (verificação habilitada).
#     Use false apenas em ambientes de teste ou com certificados auto-assinados.
#
# USO DO ARQUIVO .env:
#   Copie o arquivo .env-sample para .env e preencha com seus valores:
#
#   cp .env-sample .env
#
#   Edite o arquivo .env com suas credenciais:
#
#   ARUBA_HOST=192.168.1.1
#   ARUBA_USERNAME=admin
#   ARUBA_PASSWORD=seu_password_seguro
#   ARUBA_PORT=8443              # Opcional
#   ARUBA_SSL_VERIFY=false       # Opcional
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
if [[ -f "${SCRIPT_DIR}/commons.sh" ]]; then
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

    if [[ ! -f "${ENV_FILE}" ]]; then
        log_error "Arquivo .env não encontrado: ${ENV_FILE}"
        log_error "Crie um arquivo .env com ARUBA_HOST, ARUBA_USERNAME e ARUBA_PASSWORD"
        log_error "Você pode copiar .env-sample para .env como ponto de partida"
        return 1
    fi

    # Carrega variáveis do .env (ignora linhas vazias e comentários)
    while IFS='=' read -r key value; do
        # Remove espaços em branco e ignora comentários
        key=$(echo "${key}" | xargs)

        # Ignora linhas vazias e comentários
        [[ -z "${key}" || "${key}" =~ ^# ]] && continue

        # Remove aspas do valor se existirem
        value=$(echo "${value}" | sed -e 's/^["'"'"']//' -e 's/["'"'"']$//')

        # Exporta a variável
        export "${key}=${value}"
        log_debug "Variável carregada: ${key}"
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
        if [[ -z "${!var}" ]]; then
            missing_vars+=("${var}")
            log_error "Variável obrigatória não definida: ${var}"
        fi
    done

    if [[ ${#missing_vars[@]} -gt 0 ]]; then
        log_error "Variáveis faltando no .env: ${missing_vars[*]}"
        return 1
    fi

    # Log de variáveis opcionais se definidas
    if [[ -n "${ARUBA_PORT}" ]]; then
        log_info "Porta customizada configurada: ${ARUBA_PORT}"
    fi

    if [[ -n "${ARUBA_SSL_VERIFY}" ]]; then
        log_info "Verificação SSL configurada: ${ARUBA_SSL_VERIFY}"
    else
        log_info "Verificação SSL: usando padrão (true)"
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
    # shellcheck disable=SC2154,SC2153  # ARUBA_HOST is loaded from .env
    log_info "Host: ${ARUBA_HOST}"
    # shellcheck disable=SC2154  # ARUBA_USERNAME is loaded from .env
    log_info "Usuário: ${ARUBA_USERNAME}"

    # Define valores padrão para variáveis opcionais
    local api_version="${ARUBA_API_VERSION:-v10.13}"
    local ssl_verify="${ARUBA_SSL_VERIFY:-true}"

    # Monta o comando de autenticação
    local auth_cmd="aoscx session-login"
    auth_cmd="${auth_cmd} -i ${ARUBA_HOST}"
    auth_cmd="${auth_cmd} -u ${ARUBA_USERNAME}"
    # shellcheck disable=SC2154  # ARUBA_PASSWORD is loaded from .env
    auth_cmd="${auth_cmd} -p ${ARUBA_PASSWORD}"
    auth_cmd="${auth_cmd} --api-version ${api_version}"

    # Adiciona porta customizada se definida
    if [[ -n "${ARUBA_PORT}" ]]; then
        auth_cmd="${auth_cmd} --port ${ARUBA_PORT}"
        log_info "Usando porta customizada: ${ARUBA_PORT}"
    fi

    # Verifica se deve desabilitar verificação SSL
    # Aceita: false, no, 0 (case insensitive)
    local ssl_verify_lower
    ssl_verify_lower=$(echo "${ssl_verify}" | tr '[:upper:]' '[:lower:]')
    if [[ "${ssl_verify_lower}" == "false" || "${ssl_verify_lower}" == "no" || "${ssl_verify_lower}" == "0" ]]; then
        auth_cmd="${auth_cmd} --no-verify-ssl"
        log_warning "Verificação SSL desabilitada"
    else
        log_info "Verificação SSL habilitada"
    fi

    log_debug "Executando comando de autenticação"

    # Executa o comando e captura o resultado
    if eval "${auth_cmd}" > /dev/null 2>&1; then
        log_success "Autenticação bem-sucedida no switch Aruba"
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
    if [[ "${ARUBA_AUTHENTICATED}" = "true" ]]; then
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
    if [[ "${ARUBA_AUTHENTICATED}" != "true" ]]; then
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
    # shellcheck disable=SC2317  # Unreachable code is intentional for script/source dual usage
    return 1 2>/dev/null || exit 1
fi

# Valida as variáveis obrigatórias
if ! validate_env_vars; then
    log_error "Variáveis de ambiente inválidas"
    # shellcheck disable=SC2317  # Unreachable code is intentional for script/source dual usage
    return 1 2>/dev/null || exit 1
fi

# Autentica automaticamente
if ! aruba_authenticate; then
    log_error "Falha na autenticação inicial"
    # shellcheck disable=SC2317  # Unreachable code is intentional for script/source dual usage
    return 1 2>/dev/null || exit 1
fi

log_section "Autenticação completa - CLI pronta para uso"

# Exporta funções para uso em outros scripts
export -f aruba_authenticate
export -f aruba_check_auth
export -f aruba_logout
export -f aruba_ensure_auth

log_info "Funções exportadas: aruba_authenticate, aruba_check_auth, aruba_logout, aruba_ensure_auth"
