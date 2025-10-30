#!/bin/bash
# Instala jq localmente se necessário
if ! command -v jq >/dev/null 2>&1; then
    if [[ -d "/opt/morpheus" ]]; then
        jq_dir="/opt/morpheus/.local/bin"
    else
        jq_dir="/usr/local/bin"
    fi
    jq_path="${jq_dir}/jq"
    download_url="https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64"
    if ! mkdir -p "${jq_dir}" 2>/dev/null || ! touch "${jq_dir}/.write_test" 2>/dev/null; then
        jq_dir="${HOME}/.local/bin"
        jq_path="${jq_dir}/jq"
        mkdir -p "${jq_dir}"
    fi
    rm -f "${jq_dir}/.write_test" 2>/dev/null || true
    if command -v curl >/dev/null 2>&1; then
        curl -L -sSf -o "${jq_path}" "${download_url}"
    elif command -v wget >/dev/null 2>&1; then
        wget -q -O "${jq_path}" "${download_url}"
    else
        echo "ERROR: Neither curl nor wget are available to download jq"
        exit 1
    fi
    chmod +x "${jq_path}" 2>/dev/null || true
    export PATH="$PATH:${jq_dir}"
fi

AFC_URL="https://172.31.8.99"
USER="admin"
PASS="Aruba123!"

echo "[INFO] Autenticando..."
AUTH_RESPONSE=$(curl -sk -X POST \
    -H "X-Auth-Username: $USER" \
    -H "X-Auth-Password: $PASS" \
    -H "Content-Type: application/json" \
    -d '{"token-lifetime":30}' \
    "$AFC_URL/api/v1/auth/token")

echo "[DEBUG] Auth response: $AUTH_RESPONSE"
TOKEN=$(echo "$AUTH_RESPONSE" | jq -r '.result // .token // empty')

if [[ -z "$TOKEN" || "$TOKEN" == "null" ]]; then
    echo "[ERRO] Falha ao obter token"
    exit 1
fi

echo "[INFO] Token obtido: $TOKEN"

echo "[INFO] Buscando fabrics..."
FABRICS_RESPONSE=$(curl -sk -X GET "$AFC_URL/api/v1/fabrics?only_with_switches=true" \
    -H "accept: application/json; version=1.0" \
    -H "Authorization: $TOKEN")

echo "[INFO] Lista de fabrics encontrados (UUID  Nome):"
if echo "$FABRICS_RESPONSE" | jq -e '.result | type == "array"' >/dev/null 2>&1; then
    echo "$FABRICS_RESPONSE" | jq -r '.result[] | "\u001b[1m" + .uuid + "\u001b[0m  " + .name'
else
    echo "[ERRO] Não foi possível listar os fabrics corretamente."
fi


echo
echo "[INFO] Iniciando criação do VRF 'LoonarTeste44' no Fabric 'CEC_DSS'..."
VRF_NAME="LoonarTeste44"
FABRIC_NAME="CEC_DSS"
echo "Criando VRF: $VRF_NAME no Fabric: $FABRIC_NAME"

# Obtém o UUID do fabric pelo nome (case-insensitive, ignora espaços)
FABRIC_UUID=$(echo "$FABRICS_RESPONSE" | jq -r --arg name "$FABRIC_NAME" '
    .result[] | select((.name|ascii_downcase|gsub(" ";"")) == ($name|ascii_downcase|gsub(" ";""))) | .uuid')
if [[ -z "$FABRIC_UUID" || "$FABRIC_UUID" == "null" ]]; then
        echo "[ERRO] Não foi possível encontrar o UUID do fabric '$FABRIC_NAME'!"
        echo "[DEBUG] Nomes de fabrics disponíveis:"
        echo "$FABRICS_RESPONSE" | jq -r '.result[].name'
        exit 1
fi
echo "[INFO] UUID do fabric '$FABRIC_NAME': $FABRIC_UUID"

# Obtém e lista os switches disponíveis
SWITCH_NAME="CX10000"
SWITCHES_RESPONSE=$(curl -sk -X GET "$AFC_URL/api/v1/switches" \
    -H "accept: application/json; version=1.0" \
    -H "Authorization: $TOKEN")
echo "[INFO] Lista de switches encontrados (UUID  Nome):"
if echo "$SWITCHES_RESPONSE" | jq -e '.result | type == "array"' >/dev/null 2>&1; then
    echo "$SWITCHES_RESPONSE" | jq -r '.result[] | "\u001b[1m" + .uuid + "\u001b[0m  " + .name'
else
    echo "[ERRO] Não foi possível listar os switches corretamente."
fi

# Busca o UUID do switch pelo nome
SWITCH_UUID=$(echo "$SWITCHES_RESPONSE" | jq -r --arg name "$SWITCH_NAME" '.result[] | select(.name==$name) | .uuid')
if [[ -z "$SWITCH_UUID" || "$SWITCH_UUID" == "null" ]]; then
    echo "[ERRO] Não foi possível encontrar o UUID do switch '$SWITCH_NAME'!"
    exit 1
fi
echo "[INFO] UUID do switch '$SWITCH_NAME': $SWITCH_UUID"



# Monta o payload simples conforme solicitado
CREATE_VRF_PAYLOAD=$(cat <<EOF
{
  "name": "$VRF_NAME",
  "fabric_uuid": "$FABRIC_UUID",
  "description": "teste loonar"
}
EOF
)




# Endpoint e chamada conforme exemplo fornecido, agora com Authorization
CREATE_VRF_RESPONSE=$(curl -sk -X POST "$AFC_URL/api/vrfs" \
    -H "accept: application/json; version=1.0" \
    -H "Authorization: $TOKEN" \
    -H "Content-Type: application/json" \
    -d "$CREATE_VRF_PAYLOAD")



# Mensagem de sucesso apenas se a criação for bem-sucedida
if echo "$CREATE_VRF_RESPONSE" | jq -e '.uuid // .id // .result.uuid // .result.id // empty' >/dev/null 2>&1; then
    echo "VRF '$VRF_NAME' criado com sucesso no Fabric '$FABRIC_NAME'!"
else
    echo "[ERRO] Falha ao criar VRF. Resumo do erro da API:"
    echo "$CREATE_VRF_RESPONSE"
fi
