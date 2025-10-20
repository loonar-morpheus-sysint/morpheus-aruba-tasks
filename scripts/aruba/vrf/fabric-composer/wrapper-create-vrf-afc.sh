#!/bin/bash
################################################################################
# Script: wrapper-create-vrf-afc.sh
# Description: Wrapper para Tasks do Morpheus Data que cria VRF no HPE Aruba
#              Fabric Composer (AFC). Lê parâmetros via Groovy Template Syntax
#              (customOptions.*) e credenciais via Cypher (secret AFC_API).
################################################################################

# Primeira linha funcional: carregar biblioteca comum
# shellcheck disable=SC1091
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../../lib" && pwd)/commons.sh"

set -euo pipefail

################################################################################
# Variáveis vindas do Morpheus (Groovy Template Syntax)
# Obs.: no Morpheus, estas expressões são renderizadas antes da execução.
################################################################################
ARUBA_VRF_NAME="<%=customOptions.ARUBA_VRF_NAME%>"
ARUBA_FABRIC="<%=customOptions.ARUBA_FABRIC%>"
ARUBA_RD="<%=customOptions.ARUBA_RD%>"
ARUBA_RT_IMPORT="<%=customOptions.ARUBA_RT_IMPORT%>"
ARUBA_RT_EXPORT="<%=customOptions.ARUBA_RT_EXPORT%>"
ARUBA_AF="<%=customOptions.ARUBA_AF%>" # ipv4, ipv6, evpn (default: ipv4)
ARUBA_VNI="<%=customOptions.ARUBA_VNI%>" # L2/L3 VPN VNI (1-16777214)
ARUBA_SWITCHES="<%=customOptions.ARUBA_SWITCHES%>" # Comma-separated switch UUIDs (optional)
ARUBA_DESCRIPTION="<%=customOptions.ARUBA_DESCRIPTION%>"
MORPHEUS_DRY_RUN="<%=customOptions.DRY_RUN%>" # true/false (opcional)

# Credenciais do AFC via Cypher (JSON)
AFC_API_JSON="<%=cypher.read('AFC_API')%>"

################################################################################
# Constantes e arquivos de token (compartilhados com create-vrf-afc.sh)
################################################################################
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
API_VERSION="v1"
TOKEN_FILE="${SCRIPT_DIR}/.afc_token"
TOKEN_EXPIRY_FILE="${SCRIPT_DIR}/.afc_token_expiry"
DEFAULT_TOKEN_DURATION=1800 # 30 min

# Cleanup seguro de tokens ao finalizar (sucesso/erro/interrupção)
cleanup_tokens() {
    _log_func_enter "cleanup_tokens"
    local removed=0
    if [[ -f "${TOKEN_FILE}" ]]; then
        # Se shred estiver disponível, use para sobrescrever antes de apagar
        if command -v shred > /dev/null 2>&1; then
            shred -u -z -n 1 "${TOKEN_FILE}" 2> /dev/null || rm -f "${TOKEN_FILE}" || true
        else
            rm -f "${TOKEN_FILE}" || true
        fi
        removed=1
    fi
    if [[ -f "${TOKEN_EXPIRY_FILE}" ]]; then
        rm -f "${TOKEN_EXPIRY_FILE}" || true
        removed=1
    fi
    if [[ ${removed} -eq 1 ]]; then
        log_info "Arquivos de token do AFC removidos com segurança"
    else
        log_debug "Nenhum arquivo de token para remover"
    fi
    _log_func_exit_ok "cleanup_tokens"
    return 0
}

# Garante limpeza em qualquer término
trap cleanup_tokens EXIT INT TERM

################################################################################
# Funções auxiliares
################################################################################

check_dependencies() {
    _log_func_enter "check_dependencies"
    local deps=("curl" "jq" "sed")
    local missing=0
    for cmd in "${deps[@]}"; do
        if ! command -v "$cmd" > /dev/null 2>&1; then
            log_error "Dependência ausente: $cmd"
            missing=1
        else
            log_debug "OK: $cmd"
        fi
    done
    if [[ $missing -eq 1 ]]; then
        _log_func_exit_fail "check_dependencies" "1"
        return 1
    fi
    _log_func_exit_ok "check_dependencies"
    return 0
}

normalize_bool() {
    # converte várias formas para true/false
    local v="${1:-}"
    v=$(echo -n "$v" | tr '[:upper:]' '[:lower:]')
    case "$v" in
        1 | yes | y | true | on) echo "true" ;;
        0 | no | n | false | off | "") echo "false" ;;
        *) echo "false" ;;
    esac
}

parse_cypher_secret() {
    _log_func_enter "parse_cypher_secret"

    if [[ -z "${AFC_API_JSON}" || "${AFC_API_JSON}" == "null" ]]; then
        log_error "Cypher 'AFC_API' não retornou conteúdo"
        _log_func_exit_fail "parse_cypher_secret" "1"
        return 1
    fi

    # Extrai campos do JSON
    FABRIC_COMPOSER_USERNAME=$(echo "${AFC_API_JSON}" | jq -r '.username // empty')
    FABRIC_COMPOSER_PASSWORD=$(echo "${AFC_API_JSON}" | jq -r '.password // empty')
    local url
    url=$(echo "${AFC_API_JSON}" | jq -r '.URL // .url // empty')

    if [[ -z "${FABRIC_COMPOSER_USERNAME}" || -z "${FABRIC_COMPOSER_PASSWORD}" || -z "${url}" ]]; then
        log_error "Campos ausentes no secret AFC_API (esperado: username, password, URL)"
        _log_func_exit_fail "parse_cypher_secret" "1"
        return 1
    fi

    # Parse da URL: protocolo, host e porta
    FABRIC_COMPOSER_PROTOCOL=$(echo "$url" | sed -n 's#^\(https\?\)://.*#\1#p')
    local hostport
    hostport=$(echo "$url" | sed -n 's#^[a-zA-Z][a-zA-Z0-9+.-]*://\([^/]*\).*#\1#p')
    if [[ -z "$FABRIC_COMPOSER_PROTOCOL" ]]; then
      FABRIC_COMPOSER_PROTOCOL="https";
    fi
    if [[ -z "$hostport" ]]; then
        log_error "Não foi possível extrair host da URL do AFC"
        _log_func_exit_fail "parse_cypher_secret" "1"
        return 1
    fi
    if [[ "$hostport" == *:* ]]; then
        FABRIC_COMPOSER_IP="${hostport%%:*}"
        FABRIC_COMPOSER_PORT="${hostport##*:}"
    else
        FABRIC_COMPOSER_IP="$hostport"
        FABRIC_COMPOSER_PORT=$([[ "$FABRIC_COMPOSER_PROTOCOL" == "https" ]] && echo 443 || echo 80)
    fi

    export FABRIC_COMPOSER_USERNAME FABRIC_COMPOSER_PASSWORD FABRIC_COMPOSER_IP FABRIC_COMPOSER_PORT FABRIC_COMPOSER_PROTOCOL

    log_info "AFC alvo: ${FABRIC_COMPOSER_PROTOCOL}://${FABRIC_COMPOSER_IP}:${FABRIC_COMPOSER_PORT}"
    _log_func_exit_ok "parse_cypher_secret"
    return 0
}

validate_required_inputs() {
    _log_func_enter "validate_required_inputs"
    local errors=0

    if [[ -z "${ARUBA_VRF_NAME}" || "${ARUBA_VRF_NAME}" == "<%=customOptions.ARUBA_VRF_NAME%>" ]]; then
        log_error "Parâmetro obrigatório ausente: ARUBA_VRF_NAME"
        errors=1
    fi
    if [[ -z "${ARUBA_FABRIC}" || "${ARUBA_FABRIC}" == "<%=customOptions.ARUBA_FABRIC%>" ]]; then
        log_error "Parâmetro obrigatório ausente: ARUBA_FABRIC"
        errors=1
    fi

    if [[ ${errors} -eq 1 ]]; then
        _log_func_exit_fail "validate_required_inputs" "1"
        return 1
    fi
    _log_func_exit_ok "validate_required_inputs"
    return 0
}

authenticate_afc() {
    _log_func_enter "authenticate_afc"

    local api_url="${FABRIC_COMPOSER_PROTOCOL}://${FABRIC_COMPOSER_IP}:${FABRIC_COMPOSER_PORT}/api/${API_VERSION}/auth/token"
    local payload
    payload=$(jq -n --arg u "${FABRIC_COMPOSER_USERNAME}" --arg p "${FABRIC_COMPOSER_PASSWORD}" '{username:$u,password:$p}')

    log_info "Autenticando no AFC para obter token..."
    local response http_code body
    response=$(curl --max-time 15 --connect-timeout 5 -s -w "\n%{http_code}" -X POST \
        -H "Content-Type: application/json" \
        -d "${payload}" \
        --insecure \
        "${api_url}" 2>&1)
    http_code=$(echo "${response}" | tail -n1)
    body=$(echo "${response}" | sed '$d')

    if [[ "${http_code}" != "200" ]]; then
        log_error "Falha na autenticação do AFC (HTTP ${http_code})"
        log_error "Resposta: ${body}"
        _log_func_exit_fail "authenticate_afc" "1"
        return 1
    fi

    local token
    token=$(echo "${body}" | jq -r '.token // .access_token // empty')
    if [[ -z "${token}" || "${token}" == "null" ]]; then
        log_error "Não foi possível extrair o token de autenticação"
        _log_func_exit_fail "authenticate_afc" "1"
        return 1
    fi

    echo -n "${token}" > "${TOKEN_FILE}"
    chmod 600 "${TOKEN_FILE}"
    date +%s | {
        read -r now
        echo $((now + DEFAULT_TOKEN_DURATION))
    } > "${TOKEN_EXPIRY_FILE}"
    log_success "Token do AFC obtido com sucesso"
    _log_func_exit_ok "authenticate_afc"
    return 0
}

run_create_vrf() {
    _log_func_enter "run_create_vrf"
    local create_script="${SCRIPT_DIR}/create-vrf-afc.sh"
    if [[ ! -x "${create_script}" ]]; then
        log_error "Script não encontrado ou não executável: ${create_script}"
        _log_func_exit_fail "run_create_vrf" "1"
        return 1
    fi

    local args=("--name" "${ARUBA_VRF_NAME}" "--fabric" "${ARUBA_FABRIC}")

    # Add optional parameters only if provided
    [[ -n "${ARUBA_RD}" && "${ARUBA_RD}" != "<%=customOptions.ARUBA_RD%>" ]] && args+=("--rd" "${ARUBA_RD}")
    [[ -n "${ARUBA_RT_IMPORT}" && "${ARUBA_RT_IMPORT}" != "<%=customOptions.ARUBA_RT_IMPORT%>" ]] && args+=("--rt-import" "${ARUBA_RT_IMPORT}")
    [[ -n "${ARUBA_RT_EXPORT}" && "${ARUBA_RT_EXPORT}" != "<%=customOptions.ARUBA_RT_EXPORT%>" ]] && args+=("--rt-export" "${ARUBA_RT_EXPORT}")
    [[ -n "${ARUBA_AF}" && "${ARUBA_AF}" != "<%=customOptions.ARUBA_AF%>" ]] && args+=("--af" "${ARUBA_AF}")
    [[ -n "${ARUBA_VNI}" && "${ARUBA_VNI}" != "<%=customOptions.ARUBA_VNI%>" ]] && args+=("--vni" "${ARUBA_VNI}")
    [[ -n "${ARUBA_SWITCHES}" && "${ARUBA_SWITCHES}" != "<%=customOptions.ARUBA_SWITCHES%>" ]] && args+=("--switches" "${ARUBA_SWITCHES}")
    [[ -n "${ARUBA_DESCRIPTION}" && "${ARUBA_DESCRIPTION}" != "<%=customOptions.ARUBA_DESCRIPTION%>" ]] && args+=("--description" "${ARUBA_DESCRIPTION}")

    local dry
    dry=$(normalize_bool "${MORPHEUS_DRY_RUN:-}")
    [[ "${dry}" == "true" ]] && args+=("--dry-run") # pragma: allowlist secret

    log_info "Invocando create-vrf-afc.sh com argumentos: ${args[*]}"
    # As variáveis de credencial já estão exportadas para o ambiente
    "${create_script}" "${args[@]}"
    local rc=$?
    if [[ $rc -ne 0 ]]; then
        log_error "Falha na execução de create-vrf-afc.sh (rc=$rc)"
        _log_func_exit_fail "run_create_vrf" "$rc"
        return "$rc"
    fi
    _log_func_exit_ok "run_create_vrf"
    return 0
}

show_examples() {
    cat << 'EOF'
Exemplos locais (fora do Morpheus):
    # Exemplo básico
    export AFC_API_JSON='{"username":"admin","password":"Aruba123!","URL":"https://172.31.8.99/"}' # pragma: allowlist secret
    export ARUBA_VRF_NAME="MY-VRF"
    export ARUBA_FABRIC="fabric1"
    ./wrapper-create-vrf-afc.sh

    # Exemplo completo com todos os parâmetros
    export AFC_API_JSON='{"username":"admin","password":"Aruba123!","URL":"https://172.31.8.99/"}' # pragma: allowlist secret
    export ARUBA_VRF_NAME="PROD-VRF"
    export ARUBA_FABRIC="dc1-fabric"
    export ARUBA_RD="65000:100"
    export ARUBA_RT_IMPORT="65000:100"
    export ARUBA_RT_EXPORT="65000:100"
    export ARUBA_AF="evpn"
    export ARUBA_VNI="5000"
    export ARUBA_DESCRIPTION="Production VRF"
    ./wrapper-create-vrf-afc.sh
EOF
}

################################################################################
# Main
################################################################################
main() {
    _log_func_enter "main"
    log_section "MORPHEUS WRAPPER - CREATE VRF (AFC)"

    # Dependências
    check_dependencies

    # Inputs obrigatórios (VRF/Fabric)
    validate_required_inputs

    # Cypher -> variáveis de ambiente do AFC
    parse_cypher_secret

    # Autenticar no AFC (caching de token compatível com create-vrf-afc.sh)
    authenticate_afc

    # Executar criação da VRF
    run_create_vrf

    log_section "Concluído"
    log_success "Wrapper executado com sucesso"
    _log_func_exit_ok "main"
}

# Executa somente quando chamado diretamente
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
