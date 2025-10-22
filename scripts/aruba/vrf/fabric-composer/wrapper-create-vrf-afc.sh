#!/bin/bash
################################################################################
# Script: wrapper-create-vrf-afc.sh
# Description: Wrapper para Tasks do Morpheus Data que cria VRF no HPE Aruba
#              Fabric Composer (AFC). Lê parâmetros via Groovy Template Syntax
#              (customOptions.*) e credenciais via Cypher (secret AFC_API).
################################################################################

# Primeira linha funcional: carregar biblioteca comum
# shellcheck disable=SC1091
# Resolve path do script de forma segura para evitar "unbound variable" quando
# executado em ambientes onde BASH_SOURCE não está setado (ex.: sh -c, algumas
# plataformas de orquestração). Evita também problemas quando $0 é apenas "-c".
_resolve_script_dir() {
    # Prefer BASH_SOURCE quando disponível (bash). Use expansão segura para
    # não failar com set -u.
    local source_path
    if [ -n "${BASH_SOURCE-}" ]; then
        source_path="${BASH_SOURCE[0]}"
    else
        source_path="${0}"
    fi

    # Se o path não for absoluto, tente resolver para um path absoluto.
    if [[ "${source_path}" != /* ]]; then
        if [[ "${source_path}" == */* ]]; then
            source_path="$(pwd)/${source_path}"
        else
            # Pode estar no PATH (invocado como comando sem /) - tentar resolver.
            local resolved
            resolved=$(command -v -- "${source_path}" 2>/dev/null || true)
            if [[ -n "${resolved}" ]]; then
                source_path="${resolved}"
            else
                # Fallback conservador: usar PWD
                source_path="$(pwd)/${source_path}"
            fi
        fi
    fi

    # Melhor resolução de caminhos (symlinks)
    if command -v readlink >/dev/null 2>&1; then
        source_path=$(readlink -f -- "${source_path}" 2>/dev/null || echo "${source_path}")
    fi

    printf '%s' "$(cd "$(dirname "${source_path}")" && pwd)"
}

_find_lib_dir() {
    # Walk up parent directories from the script dir to find lib/commons.sh
    local dir
    dir="$(_resolve_script_dir)"
    while [[ -n "${dir}" && "${dir}" != "/" ]]; do
        if [[ -f "${dir}/lib/commons.sh" ]]; then
            printf '%s' "${dir}/lib"
            return 0
        fi
        dir="$(dirname "${dir}")"
    done

    # Fallback: check current working directory
    if [[ -f "$(pwd)/lib/commons.sh" ]]; then
        printf '%s' "$(pwd)/lib"
        return 0
    fi

    # Last-resort heuristic (same as older behavior), normalize the path
    local candidate
    candidate="$(_resolve_script_dir)/../../../../lib"
    if command -v readlink >/dev/null 2>&1; then
        candidate=$(readlink -f -- "${candidate}" 2>/dev/null || echo "${candidate}")
    fi
    if [[ -f "${candidate}/commons.sh" ]]; then
        printf '%s' "${candidate}"
        return 0
    fi

    return 1
}

LIB_DIR="$(_find_lib_dir)"
if [[ -z "${LIB_DIR}" ]]; then
    echo "ERROR: Unable to locate lib/commons.sh" >&2
    exit 1
fi
source "${LIB_DIR}/commons.sh"

# extract_json() is provided by lib/commons.sh

# Pre-scan arguments for --no-install
NO_INSTALL=false
for _a in "${@}"; do
    if [[ "${_a}" == "--no-install" ]]; then
        NO_INSTALL=true
        break
    fi
done

# Honor Morpheus custom option ARUBA_NO_INSTALL if provided
if [[ "${ARUBA_NO_INSTALL:-}" == "true" ]]; then
    NO_INSTALL=true
fi

_find_install_script() {
    # Walk upwards from script directory and look for utilities/install-jq.sh in
    # a few common locations (project root utilities/ or scripts/utilities/).
    local dir
    dir="$(_resolve_script_dir)"
    while [[ -n "${dir}" && "${dir}" != "/" ]]; do
        if [[ -f "${dir}/utilities/install-jq.sh" ]]; then
            printf '%s' "${dir}/utilities/install-jq.sh"
            return 0
        fi
        if [[ -f "${dir}/scripts/utilities/install-jq.sh" ]]; then
            printf '%s' "${dir}/scripts/utilities/install-jq.sh"
            return 0
        fi
        dir="$(dirname "${dir}")"
    done
    return 1
}

# Ensure jq is installed (utility may install it) unless disabled by --no-install
if [[ "${NO_INSTALL}" != "true" ]]; then
    install_script_path=""
    if install_script_path="$(_find_install_script)"; then
        log_info "Found jq installer at: ${install_script_path}. Sourcing it now."
        # shellcheck disable=SC1091
        # shellcheck source=/dev/null
        source "${install_script_path}"
        log_info "Calling ensure_jq_installed() to install/verify jq"
        if ! ensure_jq_installed; then
            log_error "jq installation or verification failed"
            log_debug "PATH after installation attempt: ${PATH}"
            exit 1
        fi
        log_info "jq verification succeeded. Current jq: $(command -v jq || echo 'none')"
    else
        log_debug "No jq installer found (searched common locations). If jq is missing, set --no-install or provide jq in PATH."
    fi
else
    log_info "--no-install specified: skipping jq installation. Ensure jq is available."
fi

set -euo pipefail

################################################################################
# Variáveis vindas do Morpheus (Groovy Template Syntax)
# Obs.: no Morpheus, estas expressões são renderizadas antes da execução.
################################################################################
ARUBA_VRF_NAME="${ARUBA_VRF_NAME:-<%=customOptions.ARUBA_VRF_NAME%>}"
ARUBA_FABRIC="${ARUBA_FABRIC:-<%=customOptions.ARUBA_FABRIC%>}"
ARUBA_RD="${ARUBA_RD:-<%=customOptions.ARUBA_RD%>}"
ARUBA_RT_IMPORT="${ARUBA_RT_IMPORT:-<%=customOptions.ARUBA_RT_IMPORT%>}"
ARUBA_RT_EXPORT="${ARUBA_RT_EXPORT:-<%=customOptions.ARUBA_RT_EXPORT%>}"
ARUBA_AF="${ARUBA_AF:-<%=customOptions.ARUBA_AF%>}"                   # ipv4, ipv6, evpn (default: ipv4)
ARUBA_VNI="${ARUBA_VNI:-<%=customOptions.ARUBA_VNI%>}"                # L2/L3 VPN VNI (1-16777214)
ARUBA_SWITCHES="${ARUBA_SWITCHES:-<%=customOptions.ARUBA_SWITCHES%>}" # Comma-separated switch UUIDs (optional)
ARUBA_DESCRIPTION="${ARUBA_DESCRIPTION:-<%=customOptions.ARUBA_DESCRIPTION%>}"
MORPHEUS_DRY_RUN="${MORPHEUS_DRY_RUN:-<%=customOptions.DRY_RUN%>}" # true/false (opcional)
ARUBA_MAX_SESSIONS_MODE="${ARUBA_MAX_SESSIONS_MODE:-<%=customOptions.ARUBA_MAX_SESSIONS_MODE%>}"
ARUBA_MAX_CPS_MODE="${ARUBA_MAX_CPS_MODE:-<%=customOptions.ARUBA_MAX_CPS_MODE%>}"
ARUBA_MAX_SESSIONS="${ARUBA_MAX_SESSIONS:-<%=customOptions.ARUBA_MAX_SESSIONS%>}"
ARUBA_MAX_CPS="${ARUBA_MAX_CPS:-<%=customOptions.ARUBA_MAX_CPS%>}"

# Credenciais do AFC via Cypher (JSON)
# Importante: o Morpheus renderiza expressões de template em qualquer lugar do
# script (inclusive comentários). Evite colocar exemplos dessa sintaxe nos
# comentários. Consulte a documentação oficial sobre renderização de templates:
# https://support.hpe.com/hpesc/public/docDisplay?docId=sd00006774en_us&page=GUID-2CE25FBB-DE0F-4B4C-8FF7-07535555A706.html
#
# Honra variável de ambiente se já definida (útil para testes locais)
# Estratégia robusta no Morpheus:
#  1) Preferir Base64 para evitar problemas de novas linhas/CR e delimitadores de here-doc
#  2) Fallback: here-doc com delimitador improvável e delimitador protegido
if [[ -z "${AFC_API_JSON:-}" ]]; then
    # Base64-safe render (quando executado no Morpheus)
    AFC_API_JSON_B64="${AFC_API_JSON_B64:-<%=java.util.Base64.getEncoder().encodeToString(cypher.read('secret/AFC_API').getBytes('UTF-8'))%>}"
    if [[ -n "${AFC_API_JSON_B64}" && "${AFC_API_JSON_B64}" != *"cypher.read"* ]]; then
        AFC_API_JSON=$(printf '%s' "${AFC_API_JSON_B64}" | base64 -d 2>/dev/null || true)
        # Remover CR se houver
        AFC_API_JSON=$(printf '%s' "${AFC_API_JSON}" | tr -d '\r')
    fi
fi
if [[ -z "${AFC_API_JSON:-}" ]]; then
    # Fallback here-doc
    AFC_API_JSON=$(
        cat <<'__AFC_CYPHER__'
'<%=cypher.read("secret/AFC_API")%>'
__AFC_CYPHER__
    )
fi

################################################################################
# Constantes e arquivos de token (compartilhados com create-vrf-afc.sh)
################################################################################
SCRIPT_DIR="$(_resolve_script_dir)"
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
        if command -v shred >/dev/null 2>&1; then
            shred -u -z -n 1 "${TOKEN_FILE}" 2>/dev/null || rm -f "${TOKEN_FILE}" || true
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
    # jq is required for JSON parsing
    local deps=("curl" "sed")
    local missing=0
    for cmd in "${deps[@]}"; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            log_error "Dependência ausente: $cmd"
            missing=1
        else
            log_debug "OK: $cmd"
        fi
    done

    if ! command -v jq >/dev/null 2>&1; then
        log_error "Dependência ausente: jq (install-jq.sh can install it, or run with --no-install after providing jq)"
        missing=1
    else
        log_debug "OK: jq"
    fi

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

    # Do not log secrets; acknowledge only
    log_debug "AFC_API_JSON received (redacted)"

    # Check if running outside Morpheus (template not rendered)
    if [[ "${AFC_API_JSON}" == *"cypher.read"* ]]; then
        log_error "AFC_API_JSON contains Groovy template syntax - script is not running in Morpheus context"
        log_error "When running locally, define the here-doc pattern:"
        log_error "  AFC_API_JSON=\$(cat <<EOF"
        log_error "  '{\"username\":\"admin\",\"password\":\"pass\",\"URL\":\"https://host/\"}'" # pragma: allowlist secret
        log_error "  EOF"
        log_error "  )"
        _log_func_exit_fail "parse_cypher_secret" "1"
        return 1
    fi

    # Extract fields using extract_json function (same pattern as working project)
    FABRIC_COMPOSER_USERNAME="$(extract_json "$AFC_API_JSON" "username")"
    FABRIC_COMPOSER_PASSWORD="$(extract_json "$AFC_API_JSON" "password")"
    local url
    url="$(extract_json "$AFC_API_JSON" "URL")"

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
        FABRIC_COMPOSER_PROTOCOL="https"
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

    # If the template was not rendered, the value stays as the literal placeholder
    if [[ -z "${ARUBA_VRF_NAME:-}" || "${ARUBA_VRF_NAME}" == "<%=customOptions.ARUBA_VRF_NAME%>" ]]; then
        log_error "Parâmetro obrigatório ausente: ARUBA_VRF_NAME"
        errors=1
    fi
    if [[ -z "${ARUBA_FABRIC:-}" || "${ARUBA_FABRIC}" == "<%=customOptions.ARUBA_FABRIC%>" ]]; then
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

    local api_base="${FABRIC_COMPOSER_PROTOCOL}://${FABRIC_COMPOSER_IP}:${FABRIC_COMPOSER_PORT}/api/${API_VERSION}/auth/token"
    local api_url_1="${api_base}"
    local api_url_2="${api_base}/" # algumas instâncias exigem barra final

    # token-lifetime em minutos (doc: padrão 30m). Nosso DEFAULT_TOKEN_DURATION é em segundos.
    local token_lifetime_min
    token_lifetime_min=$((DEFAULT_TOKEN_DURATION / 60))

    log_info "Autenticando no AFC para obter token (headers X-Auth-Username/X-Auth-Password)..."
    # Inicialize 'token' para evitar erro com 'set -u' ao checar variáveis não definidas
    local response http_code body token=""

    # Tentativa 1: Conforme documentação oficial — POST com headers X-Auth-Username / X-Auth-Password
    response=$(curl --max-time 15 --connect-timeout 5 -s -w "\n%{http_code}" -X POST \
        -H "X-Auth-Username: ${FABRIC_COMPOSER_USERNAME}" \
        -H "X-Auth-Password: ${FABRIC_COMPOSER_PASSWORD}" \
        -H "Content-Type: application/json" \
        -d "$(jq -n --argjson tl ${token_lifetime_min:-30} '{"token-lifetime": $tl}')" \
        --insecure \
        "${api_url_1}" 2>&1)
    http_code=$(echo "${response}" | tail -n1)
    body=$(echo "${response}" | sed '$d')

    if [[ "${http_code}" == "200" ]]; then
        token=$(echo "${body}" | jq -r '.result // .token // .access_token // empty')
    fi

    # Tentativa 1b: repetir com barra final no endpoint (compatibilidade)
    if [[ -z "${token}" || "${token}" == "null" || "${http_code}" == "405" || "${http_code}" == "404" ]]; then
        log_debug "Tentando novamente com barra final no endpoint /auth/token/"
        response=$(curl --max-time 15 --connect-timeout 5 -s -w "\n%{http_code}" -X POST \
            -H "X-Auth-Username: ${FABRIC_COMPOSER_USERNAME}" \
            -H "X-Auth-Password: ${FABRIC_COMPOSER_PASSWORD}" \
            -H "Content-Type: application/json" \
            -d "$(jq -n --argjson tl ${token_lifetime_min:-30} '{"token-lifetime": $tl}')" \
            --insecure \
            "${api_url_2}" 2>&1)
        http_code=$(echo "${response}" | tail -n1)
        body=$(echo "${response}" | sed '$d')
        if [[ "${http_code}" == "200" ]]; then
            token=$(echo "${body}" | jq -r '.result // .token // .access_token // empty')
        fi
    fi

    # Tentativa 2: Fallback legado — POST com corpo JSON (algumas versões aceitam)
    if [[ -z "${token}" || "${token}" == "null" ]]; then
        log_debug "Tentando POST com corpo JSON username/password (fallback legado)"
        local payload
        payload=$(jq -n --arg u "${FABRIC_COMPOSER_USERNAME}" --arg p "${FABRIC_COMPOSER_PASSWORD}" '{username:$u,password:$p}')
        response=$(curl --max-time 15 --connect-timeout 5 -s -w "\n%{http_code}" -X POST \
            -H "Content-Type: application/json" \
            -d "${payload}" \
            --insecure \
            "${api_url_1}" 2>&1)
        http_code=$(echo "${response}" | tail -n1)
        body=$(echo "${response}" | sed '$d')
        if [[ "${http_code}" == "200" ]]; then
            token=$(echo "${body}" | jq -r '.result // .token // .access_token // empty')
        fi
    fi

    # Tentativa 3: Fallback adicional — Basic Auth
    if [[ -z "${token}" || "${token}" == "null" ]]; then
        log_debug "Tentando POST com Basic Auth no header (fallback)"
        response=$(curl --max-time 15 --connect-timeout 5 -s -w "\n%{http_code}" -X POST \
            -u "${FABRIC_COMPOSER_USERNAME}:${FABRIC_COMPOSER_PASSWORD}" \
            -H "Content-Type: application/json" \
            --insecure \
            "${api_url_1}" 2>&1)
        http_code=$(echo "${response}" | tail -n1)
        body=$(echo "${response}" | sed '$d')
        if [[ "${http_code}" == "200" ]]; then
            token=$(echo "${body}" | jq -r '.result // .token // .access_token // empty')
        fi
    fi

    if [[ -z "${token}" || "${token}" == "null" ]]; then
        log_error "Falha na autenticação do AFC (HTTP ${http_code})"
        log_error "Resposta: ${body}"
        _log_func_exit_fail "authenticate_afc" "1"
        return 1
    fi

    echo -n "${token}" >"${TOKEN_FILE}"
    chmod 600 "${TOKEN_FILE}"
    date +%s | {
        read -r now
        echo $((now + DEFAULT_TOKEN_DURATION))
    } >"${TOKEN_EXPIRY_FILE}"
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
    [[ -n "${ARUBA_MAX_SESSIONS_MODE}" && "${ARUBA_MAX_SESSIONS_MODE}" != "<%=customOptions.ARUBA_MAX_SESSIONS_MODE%>" ]] && args+=("--max-sessions-mode" "${ARUBA_MAX_SESSIONS_MODE}")
    [[ -n "${ARUBA_MAX_CPS_MODE}" && "${ARUBA_MAX_CPS_MODE}" != "<%=customOptions.ARUBA_MAX_CPS_MODE%>" ]] && args+=("--max-cps-mode" "${ARUBA_MAX_CPS_MODE}")
    [[ -n "${ARUBA_MAX_SESSIONS}" && "${ARUBA_MAX_SESSIONS}" != "<%=customOptions.ARUBA_MAX_SESSIONS%>" ]] && args+=("--max-sessions" "${ARUBA_MAX_SESSIONS}")
    [[ -n "${ARUBA_MAX_CPS}" && "${ARUBA_MAX_CPS}" != "<%=customOptions.ARUBA_MAX_CPS%>" ]] && args+=("--max-cps" "${ARUBA_MAX_CPS}")
    # Propagate no-install flag
    if [[ "${NO_INSTALL}" == "true" || "${ARUBA_NO_INSTALL:-}" == "true" ]]; then
        args+=("--no-install")
    fi

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
    cat <<'EOF'
Exemplos locais (fora do Morpheus):
    # Simular renderização do Morpheus com here-doc e single-quote
    AFC_API_JSON=$(cat <<EOF_INNER
    '{"username":"<USERNAME>","password":"<PASSWORD>","URL":"https://afc.example.local/"}' # pragma: allowlist secret
    EOF_INNER
    )
    export AFC_API_JSON
    export ARUBA_VRF_NAME="MY-VRF"
    export ARUBA_FABRIC="fabric1"
    ./wrapper-create-vrf-afc.sh

    # Exemplo completo com todos os parâmetros
    AFC_API_JSON=$(cat <<EOF_INNER
    '{"username":"<USERNAME>","password":"<PASSWORD>","URL":"https://afc.example.local/"}' # pragma: allowlist secret
    EOF_INNER
    )
    export AFC_API_JSON
    export ARUBA_VRF_NAME="PROD-VRF"
    export ARUBA_FABRIC="dc1-fabric"
    export ARUBA_RD="65000:100"
    export ARUBA_RT_IMPORT="65000:100"
    export ARUBA_RT_EXPORT="65000:100"
    export ARUBA_AF="evpn"
    export ARUBA_VNI="5000"
    export ARUBA_SWITCHES="switch-uuid-1,switch-uuid-2"
    export ARUBA_DESCRIPTION="Production VRF"
    export ARUBA_MAX_SESSIONS_MODE="limited"
    export ARUBA_MAX_SESSIONS="10000"
    export ARUBA_MAX_CPS_MODE="limited"
    export ARUBA_MAX_CPS="1000"
    # Skip installer (no jq installation)
    ./wrapper-create-vrf-afc.sh --no-install
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
if [[ "$(_resolve_script_dir)" == "$(cd "$(dirname "${0}")" && pwd)" ]]; then
    main "$@"
fi
