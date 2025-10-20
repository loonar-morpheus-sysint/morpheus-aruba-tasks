# wrapper-create-vrf-afc.sh

Guia rápido para o wrapper de criação de VRF no HPE Aruba Fabric Composer (AFC) integrado ao Morpheus Data.

## Visão geral

O script `wrapper-create-vrf-afc.sh` é um wrapper pensado para ser usado como Task no Morpheus Data. Ele:

- Lê parâmetros de formulário via Groovy Template Syntax (customOptions.*)
- Obtém credenciais do AFC a partir do Cypher (secret `AFC_API`)
- Autentica no AFC (gera token temporário)
- Invoca o script principal `create-vrf-afc.sh` com os argumentos corretos
- Remove com segurança os arquivos de token ao final da execução (trap com shred quando disponível)

## Entradas suportadas (via customOptions)

Defina no Form/Options do Morpheus os seguintes campos (nomes exatamente como abaixo):

Obrigatórios:

- `ARUBA_VRF_NAME` — Nome da VRF (ex.: PROD-VRF)
- `ARUBA_FABRIC` — Nome do fabric no AFC (ex.: dc1-fabric)

Opcionais:

- `ARUBA_RD` — Route Distinguisher (ex.: 65000:100)
- `ARUBA_RT_IMPORT` — Route Target Import (ex.: `65000:100,65000:200`)
- `ARUBA_RT_EXPORT` — Route Target Export (ex.: `65000:100,65000:200`)
- `ARUBA_AF` — Address Family (ex.: `ipv4`, `ipv6` ou `ipv4,ipv6`)
- `ARUBA_DESCRIPTION` — Descrição da VRF
- `DRY_RUN` — `true`/`false` para validar sem criar/aplicar

No corpo do script, estes valores são referenciados assim:

```bash
ARUBA_VRF_NAME="<%=customOptions.ARUBA_VRF_NAME%>"
ARUBA_FABRIC="<%=customOptions.ARUBA_FABRIC%>"
ARUBA_RD="<%=customOptions.ARUBA_RD%>"
ARUBA_RT_IMPORT="<%=customOptions.ARUBA_RT_IMPORT%>"
ARUBA_RT_EXPORT="<%=customOptions.ARUBA_RT_EXPORT%>"
ARUBA_AF="<%=customOptions.ARUBA_AF%>"
ARUBA_DESCRIPTION="<%=customOptions.ARUBA_DESCRIPTION%>"
MORPHEUS_DRY_RUN="<%=customOptions.DRY_RUN%>"
```

## Credenciais via Cypher

Crie no Morpheus Cypher um secret chamado `AFC_API` contendo JSON no formato:

```json
{
  "username": "<USER>",
  "password": "<PASSWORD>", <!-- pragma: allowlist secret -->
  "URL": "https://<AFC URL>/"
}
```

O wrapper lê este valor com:

```bash
AFC_API_JSON="<%=cypher.read('AFC_API')%>"
```

Em seguida, extrai `username`, `password` e `URL`, analisando protocolo, host e porta para exportar as variáveis esperadas pelo script principal (`FABRIC_COMPOSER_USERNAME`, `FABRIC_COMPOSER_PASSWORD`, `FABRIC_COMPOSER_IP`, `FABRIC_COMPOSER_PORT`, `FABRIC_COMPOSER_PROTOCOL`).

## Fluxo de execução

1. Valida dependências (`curl`, `jq`, `sed`; `shred` opcional)
2. Valida entradas obrigatórias (`ARUBA_VRF_NAME`, `ARUBA_FABRIC`)
3. Lê e valida o secret `AFC_API` no Cypher
4. Autentica no AFC (`/api/v1/auth/token`) e salva token temporariamente
5. Invoca `create-vrf-afc.sh` com os argumentos mapeados
6. Limpa com segurança os arquivos de token ao final (trap)

Arquivos de token temporários (no mesmo diretório do wrapper):

- `.afc_token`
- `.afc_token_expiry`

Estes arquivos são sempre removidos ao término (EXIT/INT/TERM), usando `shred` quando disponível.

## Requisitos para executar no Morpheus (Task)

- Tipo da Task: Shell (Bash)
- Conteúdo: o arquivo `wrapper-create-vrf-afc.sh` (ou referenciá-lo a partir do repositório)
- Form/Options: definir os campos descritos em “Entradas suportadas”
- Cypher: secret `AFC_API` existente e acessível
- Permissões: a Task/Usuário precisa ter acesso ao Cypher `AFC_API`
- Ambiente de execução precisa ter as dependências:
  - `bash`, `curl`, `jq`, `sed`
  - `shred` (opcional, para limpeza segura do token)

## Exemplo de uso (Morpheus)

- Crie/edit um Form/Option Type com os campos:
  - `ARUBA_VRF_NAME` (text, required)
  - `ARUBA_FABRIC` (text, required)
  - `ARUBA_RD` (text, optional)
  - `ARUBA_RT_IMPORT` (text, optional)
  - `ARUBA_RT_EXPORT` (text, optional)
  - `ARUBA_AF` (select: `ipv4`, `ipv6`, `ipv4,ipv6`, optional)
  - `ARUBA_DESCRIPTION` (text, optional)
  - `DRY_RUN` (boolean, optional)
- Garanta o Cypher `AFC_API` conforme o JSON acima
- Associe esse Form à Task que contém o script wrapper
- Execute a Task passando os valores desejados

## Troubleshooting

- 401/403: verifique `username/password` e permissões no AFC; cheque o `URL` do secret
- Certificados: se o AFC usa certificado não confiável, o wrapper usa `--insecure` no `curl`
- `DRY_RUN=true`: o wrapper valida, mas o `create-vrf-afc.sh` não aplica alterações

## Referências

- AFC API Getting Started: <https://developer.arubanetworks.com/afc/docs/getting-started-with-the-afc-api>
- VRF (AFC Online Help): <https://arubanetworking.hpe.com/techdocs/AFC/700/Content/afc70olh/add-vrf.htm>
- Authentication API: <https://developer.arubanetworks.com/afc/reference/getapikey-1>
- Ansible (referência de implementação AFC): <https://github.com/aruba/hpeanfc-ansible-collection>
- Morpheus Data — Cypher (docs): <https://docs.morpheusdata.com/>
- Morpheus Data — Groovy Template Syntax (docs): <https://docs.morpheusdata.com/>
