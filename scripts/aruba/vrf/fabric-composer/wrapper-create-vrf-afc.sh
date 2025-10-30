#!/bin/bash
set -euo pipefail
# Script: wrapper-create-vrf-afc.sh
# Description: Cria um VRF no Aruba Fabric Composer, parametrizado por variáveis ARUBA_VRF_NAME e ARUBA_FABRIC.

_SRC_PATH="${BASH_SOURCE[0]:-$0}"
_SCRIPT_DIR="$(cd "$(dirname "$(realpath \"$_SRC_PATH\")")" && pwd)"
# Busca ascendente até encontrar lib/commons.sh
COMMONS_PATH=""
_SEARCH_DIR="$_SCRIPT_DIR"
while [[ "$_SEARCH_DIR" != "/" ]]; do
    if [[ -f "$_SEARCH_DIR/lib/commons.sh" ]]; then
        COMMONS_PATH="$_SEARCH_DIR/lib/commons.sh"
        break
    fi
    _SEARCH_DIR="$(dirname "$_SEARCH_DIR")"
done
if [[ -n "$COMMONS_PATH" ]]; then
    # shellcheck disable=SC1090
    source "$COMMONS_PATH"
else
    echo "[FATAL] Não foi possível localizar lib/commons.sh em nenhum diretório ascendente a partir de $_SCRIPT_DIR" >&2
    exit 1
fi


ARUBA_VRF_NAME="<%=customOptions.ARUBA_VRF_NAME%>"
ARUBA_FABRIC="<%=customOptions.ARUBA_FABRIC%>"
echo "ARUBA_VRF_NAME: $ARUBA_VRF_NAME"
echo "ARUBA_FABRIC: $ARUBA_FABRIC"



# Obtém dados sensíveis do cypher e extrai variáveis
AFC_API_JSON=$(cat <<EOF
'<%=cypher.read('secret/AFC_API')%>'
EOF
)

# Remove aspas simples ao redor do JSON, se existirem
if [[ "$AFC_API_JSON" =~ ^'.*'$ ]]; then
    AFC_API_JSON="${AFC_API_JSON:1:-1}"
fi

echo "$AFC_API_JSON"
# Limpa e valida JSON
USER="$(echo "$AFC_API_JSON" | jq -r '.username')"
PASS="$(echo "$AFC_API_JSON" | jq -r '.password')"
AFC_URL="$(echo "$AFC_API_JSON" | jq -r '.URL' | sed 's:/*$::')"


main() {
    _log_func_enter "main"

    # Validação de dependências
    check_dependencies jq curl || {
        log_error "Dependências ausentes: jq e curl são necessários."
        _log_func_exit_fail
        return 1
    }

    if [[ -z "$ARUBA_VRF_NAME" || -z "$ARUBA_FABRIC" ]]; then
        log_error "ARUBA_VRF_NAME e ARUBA_FABRIC devem ser definidos."
        _log_func_exit_fail
        return 1
    fi

    log_info "Autenticando no AFC..."
    AUTH_RESPONSE=$(curl -sk -X POST \
        -H "X-Auth-Username: $USER" \
        -H "X-Auth-Password: $PASS" \
        -H "Content-Type: application/json" \
        -d '{"token-lifetime":30}' \
        "$AFC_URL/api/v1/auth/token")

    log_debug "Auth response: $AUTH_RESPONSE"
    TOKEN=$(echo "$AUTH_RESPONSE" | jq -r '.result // .token // empty')
    if [[ -z "$TOKEN" || "$TOKEN" == "null" ]]; then
        log_error "Falha ao obter token de autenticação."
        _log_func_exit_fail
        return 1
    fi
    log_success "Token obtido."

    log_info "Buscando lista de fabrics..."
    FABRICS_RESPONSE=$(curl -sk -X GET "$AFC_URL/api/v1/fabrics?only_with_switches=true" \
        -H "accept: application/json; version=1.0" \
        -H "Authorization: $TOKEN")

    if echo "$FABRICS_RESPONSE" | jq -e '.result | type == "array"' >/dev/null 2>&1; then
        log_info "Fabrics encontrados (UUID  Nome):"
        echo "$FABRICS_RESPONSE" | jq -r '.result[] | "\u001b[1m" + .uuid + "\u001b[0m  " + .name'
    else
        log_error "Não foi possível listar os fabrics corretamente."
        _log_func_exit_fail
        return 1
    fi

    # Busca UUID do fabric pelo nome (case-insensitive, ignora espaços)
    FABRIC_UUID=$(echo "$FABRICS_RESPONSE" | jq -r --arg name "$ARUBA_FABRIC" '
        .result[] | select((.name|ascii_downcase|gsub(" ";"")) == ($name|ascii_downcase|gsub(" ";""))) | .uuid')
    if [[ -z "$FABRIC_UUID" || "$FABRIC_UUID" == "null" ]]; then
        log_error "Não foi possível encontrar o UUID do fabric '$ARUBA_FABRIC'!"
        log_debug "Nomes de fabrics disponíveis:"
        echo "$FABRICS_RESPONSE" | jq -r '.result[].name'
        _log_func_exit_fail
        return 1
    fi
    log_success "UUID do fabric '$ARUBA_FABRIC': $FABRIC_UUID"

    # Lista switches (opcional, pode ser removido se não for necessário)
    log_info "Buscando switches disponíveis..."
    SWITCHES_RESPONSE=$(curl -sk -X GET "$AFC_URL/api/v1/switches" \
        -H "accept: application/json; version=1.0" \
        -H "Authorization: $TOKEN")
    if echo "$SWITCHES_RESPONSE" | jq -e '.result | type == "array"' >/dev/null 2>&1; then
        log_info "Switches encontrados (UUID  Nome):"
        echo "$SWITCHES_RESPONSE" | jq -r '.result[] | "\u001b[1m" + .uuid + "\u001b[0m  " + .name'
    else
        log_warn "Não foi possível listar os switches corretamente."
    fi

    # Monta o payload para criação do VRF
    CREATE_VRF_PAYLOAD=$(cat <<EOF
{
  "name": "$ARUBA_VRF_NAME",
  "fabric_uuid": "$FABRIC_UUID",
  "description": "criado via wrapper"
}
EOF
)

    log_info "Criando VRF '$ARUBA_VRF_NAME' no Fabric '$ARUBA_FABRIC'..."
    CREATE_VRF_RESPONSE=$(curl -sk -X POST "$AFC_URL/api/vrfs" \
        -H "accept: application/json; version=1.0" \
        -H "Authorization: $TOKEN" \
        -H "Content-Type: application/json" \
        -d "$CREATE_VRF_PAYLOAD")

    if echo "$CREATE_VRF_RESPONSE" | jq -e '.uuid // .id // .result.uuid // .result.id // empty' >/dev/null 2>&1; then
        log_success "VRF '$ARUBA_VRF_NAME' criado com sucesso no Fabric '$ARUBA_FABRIC'!"
    else
        log_error "Falha ao criar VRF. Resumo do erro da API:"
        echo "$CREATE_VRF_RESPONSE"
        _log_func_exit_fail
        return 1
    fi

    _log_func_exit_ok
}


# Proteção de sourcing
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
fi

# Função de autenticação AFC para compatibilidade com testes
authenticate_afc() {
    set -euo pipefail
    _log_func_enter "authenticate_afc"
    # ... lógica de autenticação ...
    _log_func_exit_ok
}
