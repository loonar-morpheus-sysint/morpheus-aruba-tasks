# VRF Hybrid Script - Prompt para Recriação

## Objetivo

Este documento contém o prompt necessário para instruir um agente de IA (como GitHub Copilot) a criar o script híbrido `scripts/hybrid/create-vrf-hybrid.sh` com todos os refinamentos e funcionalidades implementadas.

---

## Prompt Completo

```markdown
Preciso que você crie um script Bash chamado `scripts/hybrid/create-vrf-hybrid.sh` que suporte a criação de VRFs (Virtual Routing and Forwarding) em ambientes Aruba através de DUAS APIs diferentes:

### 1. APIs Suportadas

**API 1: Aruba Fabric Composer (AFC)**
- Endpoint base: `https://<FABRIC_COMPOSER_IP>:<PORT>/api/v1`
- Autenticação: JWT Bearer Token
- Endpoint de criação: `/api/v1/sites/default/vrfs`
- Endpoint de aplicação: `/api/v1/sites/default/vrfs/{uuid}/apply`
- Requer: Fabric name, suporta array de switches

**API 2: AOS-CX REST API**
- Endpoint base: `https://<SWITCH_IP>:<PORT>/rest/v10.15`
- Autenticação: Basic Auth ou custom
- Endpoint de criação: `/rest/v10.15/system/vrfs`
- Criação direta no switch, sem apply step

### 2. Requisitos Técnicos Obrigatórios

**Estrutura do Script:**
1. Header EXATO conforme AGENTS.md:
   ```bash
   #!/bin/bash
   ###########################################################################
   # Script: create-vrf-hybrid.sh
   # Description: Create VRF supporting both Fabric Composer and AOS-CX APIs
   ###########################################################################
   ```

2. Source do commons.sh como primeira linha funcional:

   ```bash
   source "$(dirname "${BASH_SOURCE[0]}")/commons.sh"
   ```

3. Função main() com proteção de sourcing:

   ```bash
   main() {
     _log_func_enter "main"
     # lógica aqui
     _log_func_exit_ok "main"
   }

   if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
     main "$@"
   fi
   ```

4. TODAS as funções DEVEM ter:
   - `_log_func_enter "nome_funcao"` como primeira linha
   - `_log_func_exit_ok "nome_funcao"` antes de `return 0`
   - `_log_func_exit_fail "nome_funcao" "codigo"` antes de `return 1`

5. Nomenclatura:
   - Variáveis globais: `UPPERCASE_WITH_UNDERSCORE`
   - Variáveis locais: `lowercase_with_underscore`
   - Funções: `verb_noun()` com underscore
   - Nomes em inglês (priorizar legibilidade)

### 3. Parâmetros Suportados

**Parâmetros Comuns (ambos os modos):**

- `--mode <fabric-composer|aos-cx>` (OBRIGATÓRIO)
- `--name <vrf_name>` (OBRIGATÓRIO)
- `--description <text>`
- `--env-file <path>` (carregar credenciais)
- `--dry-run` (mostrar payload sem executar)
- `--no-install` (não instalar dependências automaticamente)

**Parâmetros Específicos do Fabric Composer (12):**

- `--fabric <fabric_name>` (OBRIGATÓRIO no modo AFC)
- `--switches <switch1,switch2,...>` (array de switches)
- `--rd <route_distinguisher>` (ex: 65000:100)
- `--rt-import <route_target>` (pode ser múltiplo)
- `--rt-export <route_target>` (pode ser múltiplo)
- `--af <ipv4|ipv6>` (address family)
- `--l3-vni <number>` (Layer 3 VNI)
- `--enable-conn-tracking` (flag booleana)
- `--allow-session-reuse` (flag booleana)
- `--enable-ip-fragment` (flag booleana)
- `--no-apply` (não executar apply step)
- `--token-refresh-margin <seconds>` (default: 300)

**Parâmetros Específicos do AOS-CX (13):**

- `--switch <hostname>` (OBRIGATÓRIO no modo AOS-CX)
- `--rt-af <ipv4-unicast|ipv6-unicast>` (address family para route target)
- `--rt-mode <import|export|both>` (route mode)
- `--rt-community <value>` (extended community)
- `--bgp-bestpath` (flag: enable BGP bestpath)
- `--bgp-fast-fallover` (flag: enable fast external fallover)
- `--bgp-trap` (flag: enable trap)
- `--bgp-log-neighbor` (flag: log neighbor changes)
- `--bgp-deterministic-med` (flag: deterministic MED)
- `--bgp-always-compare-med` (flag: always compare MED)
- `--max-sessions <number>` (max concurrent sessions)
- `--max-cps <number>` (max connections per second)
- `--max-sessions-mode <unlimited|limited>` (mode for max sessions; AFC wrapper exposes ARUBA_MAX_SESSIONS_MODE)
- `--max-cps-mode <unlimited|limited>` (mode for max cps; AFC wrapper exposes ARUBA_MAX_CPS_MODE)
- `--api-version <version>` (default: v10.15)

### 4. Funcionalidades Obrigatórias

**Gerenciamento de Token (AFC):**

- Função `get_afc_token()` para obter JWT token
- Salvar token em `.afc_token` e expiry em `.afc_token_expiry`
- Função `afc_token_needs_refresh()` para verificar se precisa renovar
- Renovar automaticamente se estiver próximo da expiração (300s margin)

**Validações:**

- Função `check_dependencies()` validando: curl, jq, date
- Função `validate_afc_environment()` para variáveis AFC
- Função `validate_afc_config()` para parâmetros AFC
- Função `validate_aoscx_environment()` para variáveis AOS-CX
- Função `validate_aoscx_config()` para parâmetros AOS-CX

**Construção de Payloads:**

- Função `build_afc_payload()` construindo JSON para AFC:

  ```json
  {
    "name": "VRF-NAME",
    "fabric": "fabric-name",
    "switches": ["switch1", "switch2"],
    "route_distinguisher": "65000:100",
    "route_targets": {
      "import": ["65000:100"],
      "export": ["65000:100"]
    },
    "address_family": ["ipv4"],
    "l3_vni": 10000,
    "enable_connection_tracking_mode": true,
    "allow_session_reuse": false,
    "enable_ip_fragment_forwarding": false
  }
  ```

- Função `build_aoscx_payload()` construindo JSON para AOS-CX:

  ```json
  {
    "name": "VRF-NAME",
    "route_target": {
      "primary_route_target": {
        "address_family": "ipv4-unicast",
        "route_mode": "both",
        "ext_community": "target:65000:100"
      }
    },
    "bgp": {
      "bestpath": true,
      "fast_external_fallover": true,
      "trap_enable": true,
      "log_neighbor_changes": true,
      "deterministic_med": false,
      "always_compare_med": false
    },
    "max_sessions_mode": "static",
    "max_sessions": 10000,
    "max_cps_mode": "static",
    "max_cps": 1000
  }
  ```

**Execução:**

- Função `create_vrf_afc()` fazendo POST para `/api/v1/sites/default/vrfs`
- Capturar UUID da resposta: `VRF_UUID=$(echo "${response}" | jq -r '.uuid // .id // empty')`
- Função `apply_vrf_afc()` fazendo POST para `/api/v1/sites/default/vrfs/${VRF_UUID}/apply`
- Função `create_vrf_aoscx()` fazendo POST para `/rest/v10.15/system/vrfs`

**Roteamento de Modo:**

- No main(), verificar `OPERATION_MODE` e rotear para funções corretas:

  ```bash
  if [[ "${OPERATION_MODE}" == "fabric-composer" ]]; then
    validate_afc_environment && validate_afc_config && create_vrf_afc && apply_vrf_afc
  elif [[ "${OPERATION_MODE}" == "aos-cx" ]]; then
    validate_aoscx_environment && validate_aoscx_config && create_vrf_aoscx
  fi
  ```

### 5. Configuração do .env

O script deve suportar arquivo .env com as seguintes variáveis:

```bash
# Fabric Composer
FABRIC_COMPOSER_IP=172.31.8.99
FABRIC_COMPOSER_USERNAME=admin
FABRIC_COMPOSER_PASSWORD=Aruba123!
FABRIC_COMPOSER_PORT=443
FABRIC_COMPOSER_PROTOCOL=https
TOKEN_REFRESH_MARGIN=300

# AOS-CX
AOSCX_SWITCH_IP=10.0.0.1
AOSCX_USERNAME=admin
AOSCX_PASSWORD=password
AOSCX_PORT=443
AOSCX_PROTOCOL=https
AOSCX_API_VERSION=v10.15
```

### 6. Funcionalidades Adicionais

**Help Completo:**

- Função `show_usage()` mostrando:
  - Sintaxe básica
  - Todos os 30 parâmetros (5 comuns + 12 AFC + 13 AOS-CX)
  - Exemplos de uso para ambos os modos
  - Variáveis de ambiente esperadas

**Dry-Run:**

- Se `--dry-run` fornecido, apenas mostrar payload e não executar
- Usar `log_info` para mostrar payload formatado com jq

**Logging:**

- Usar funções do commons.sh: `log_section`, `log_info`, `log_success`, `log_error`, `log_debug`
- Logging estruturado em todas as operações críticas

**Tratamento de Erros:**

- Verificar HTTP status codes
- Retornar códigos apropriados (0 = sucesso, 1 = erro)
- Mensagens de erro descritivas

### 7. Scripts de Teste

Crie também dois scripts de teste:

**test-hybrid-afc.sh:**

```bash
#!/bin/bash
./create-vrf-hybrid.sh \
  --mode fabric-composer \
  --env-file .env \
  --name TEST-VRF-AFC \
  --fabric default \
  --rd 65000:999 \
  --rt-import "65000:999" \
  --rt-export "65000:999" \
  --af ipv4 \
  --dry-run
```

**test-hybrid-aoscx.sh:**

```bash
#!/bin/bash
./create-vrf-hybrid.sh \
  --mode aos-cx \
  --switch cx10000.local \
  --name TEST-VRF-AOSCX \
  --bgp-bestpath \
  --bgp-fast-fallover \
  --bgp-log-neighbor \
  --max-sessions 10000 \
  --max-cps 1000 \
  --dry-run
```

### 8. Documentação

Crie também `QUICKSTART_VRF_HYBRID.md` contendo:

- Descrição do script
- Pré-requisitos (curl, jq, bash 4+)
- Instalação
- Configuração do .env
- Todos os parâmetros explicados
- 5 exemplos completos de uso
- Troubleshooting comum

### 9. Validações Finais

O script deve passar nos seguintes testes:

- `shellcheck create-vrf-hybrid.sh` (máximo 1 warning sobre INTERACTIVE_MODE)
- `./create-vrf-hybrid.sh --help` deve funcionar
- Todas as funções devem ter logging completo
- Seguir 100% os padrões do AGENTS.md
- Variáveis globais em UPPERCASE, locais em lowercase
- Nome de arquivo em kebab-case
- Permissões executáveis (chmod +x)

### 10. Estatísticas Esperadas

O script final deve ter aproximadamente:

- ~1100 linhas de código
- 22 funções
- 30 parâmetros configuráveis
- 2 modos de operação
- Suporte a 2 APIs diferentes

```text

---

## Contexto Adicional

### Histórico de Refinamentos

Este script foi criado através de um processo iterativo que incluiu:

1. **Análise inicial**: Comparação de três abordagens diferentes para criação de VRFs
2. **Correção do script original**: Adição do apply step no `scripts/hybrid/create-aruba-vrf.sh`
3. **Comparação de parâmetros**: Análise detalhada dos parâmetros suportados por cada API
4. **Implementação híbrida**: Criação do script unificado suportando ambas as APIs
5. **Validação**: Testes com shellcheck, verificação de logging, conformidade com AGENTS.md

### Lições Aprendidas

1. **Apply Step é Crítico**: No Fabric Composer, criar VRF não é suficiente - é necessário fazer apply
2. **Endpoint Correto**: Use `/api/v1/sites/default/vrfs` (não `/api/v1/vrfs`)
3. **UUID é Essencial**: Capture o UUID da resposta de criação para usar no apply
4. **Token Management**: Implemente cache e refresh automático para evitar calls desnecessários
5. **Modo Selecionável**: Melhor que auto-detecção - mais claro e explícito
6. **Validação em Camadas**: Ambiente → Configuração → Parâmetros → Payload

### Arquivos Relacionados

- `scripts/hybrid/create-vrf-hybrid.sh` - Script principal (~1100 linhas)
- `QUICKSTART_VRF_HYBRID.md` - Guia de uso completo
- `VRF_PARAMETERS_COMPARISON.md` - Comparação detalhada de parâmetros
- `VRF_HYBRID_IMPLEMENTATION_SUMMARY.md` - Resumo da implementação
- `test-hybrid-afc.sh` - Script de teste para modo AFC
- `test-hybrid-aoscx.sh` - Script de teste para modo AOS-CX
- `.env` - Arquivo de configuração com credenciais

---

## Como Usar Este Prompt

### Opção 1: Prompt Direto

Copie todo o conteúdo da seção "Prompt Completo" e forneça ao agente de IA.

### Opção 2: Prompt com Contexto

Forneça o prompt junto com os arquivos de referência:
- `commons.sh` (biblioteca de logging)
- `AGENTS.md` (padrões de desenvolvimento)
- `.env.example` (exemplo de configuração)

### Opção 3: Prompt Incremental

Divida o prompt em etapas:
1. Estrutura básica e modo selection
2. Implementação do modo Fabric Composer
3. Implementação do modo AOS-CX
4. Validações e tratamento de erros
5. Documentação e testes

---

## Verificação de Qualidade

Após a criação do script, verifique:

```bash
# 1. Validação com shellcheck
shellcheck create-vrf-hybrid.sh

# 2. Teste de help
./create-vrf-hybrid.sh --help

# 3. Teste dry-run AFC
./test-hybrid-afc.sh

# 4. Teste dry-run AOS-CX
./test-hybrid-aoscx.sh

# 5. Verificação de estrutura
grep -c "_log_func_enter" create-vrf-hybrid.sh  # Deve ser ~22
grep -c "_log_func_exit" create-vrf-hybrid.sh   # Deve ser ~44
grep -c "return 0" create-vrf-hybrid.sh         # Cada um deve ter _log_func_exit_ok antes
```

---

## Notas Importantes

1. **Credenciais de Teste**: O Fabric Composer de teste está em `172.31.8.99` (admin/Aruba123!)
2. **Insecure Flag**: Use `curl --insecure` porque os ambientes usam certificados autoassinados
3. **jq é Obrigatório**: Necessário para construção e parsing de JSON
4. **Bash 4+**: Requerido para arrays associativos e recursos modernos
5. **commons.sh**: Deve existir no mesmo diretório que o script

---

## Autor

Documento criado a partir da implementação realizada em outubro de 2025.

**Última Atualização**: 2025-10-19

---

## Referências

- [AGENTS.md](docs/AGENTS.md) - Padrões de desenvolvimento para agentes
- [QUICKSTART_VRF_HYBRID.md](QUICKSTART_VRF_HYBRID.md) - Guia de uso do script
- [VRF_PARAMETERS_COMPARISON.md](VRF_PARAMETERS_COMPARISON.md) - Comparação de parâmetros
- [VRF_HYBRID_IMPLEMENTATION_SUMMARY.md](VRF_HYBRID_IMPLEMENTATION_SUMMARY.md) - Resumo da implementação
