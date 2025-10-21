# Comparação Detalhada de Parâmetros - VRF APIs

## 📊 Visão Geral

Este documento mapeia **todos os parâmetros** suportados pelas duas APIs:

1. **Fabric Composer API** (`/api/v1/sites/default/vrfs`)
2. **AOS-CX REST API** (`/api/v10.15/system/vrfs`)

---

## 🔑 Parâmetros Comuns (Mapeáveis)

| Parâmetro | Fabric Composer | AOS-CX REST | Mapeamento | Compatível |
|-----------|-----------------|-------------|------------|------------|
| **Nome da VRF** | `name` (string) | `name` (string) | Direto | ✅ 100% |
| **Descrição** | `description` (string) | ❌ Não suportado | N/A | ⚠️ Apenas AFC |

---

## 📋 Tabela Completa de Parâmetros

### 1️⃣ Fabric Composer API

#### Parâmetros Básicos

| Parâmetro | Tipo | Obrigatório | Descrição | Exemplo |
|-----------|------|-------------|-----------|---------|
| `name` | string | ✅ Sim | Nome da VRF | `"PROD-VRF"` |
| `description` | string | ❌ Não | Descrição da VRF | `"VRF de Produção"` |
| `fabric` | string | ✅ Sim | Nome do fabric | `"default"` ou `"dc1-fabric"` |

#### Parâmetros de Switch/Infraestrutura

| Parâmetro | Tipo | Obrigatório | Descrição | Exemplo |
|-----------|------|-------------|-----------|---------|
| `switches` | array[string] | ❌ Não | Lista de switches | `["CX10000", "CX10001"]` |

#### Parâmetros de Roteamento

| Parâmetro | Tipo | Obrigatório | Descrição | Exemplo |
|-----------|------|-------------|-----------|---------|
| `route_distinguisher` | string | ❌ Não | Route Distinguisher | `"65000:100"` ou `"loopback0"` |
| `route_targets` | array[object] | ❌ Não | Route Targets (import/export) | Ver estrutura abaixo |
| `address_family` | array[string] | ❌ Não | Famílias de endereço | `["ipv4"]` ou `["ipv4", "ipv6"]` |

**Estrutura de `route_targets`:**

```json
[
  {
    "mode": "Import",                    // "Import" | "Export" | "Both"
    "ext_community": "65000:100",
    "address_family": "IPv4 Unicast"     // "IPv4 Unicast" | "IPv6 Unicast" | "EVPN"
  }
]
```

#### Parâmetros VXLAN/EVPN

| Parâmetro | Tipo | Obrigatório | Descrição | Exemplo |
|-----------|------|-------------|-----------|---------|
| `l3_vni` | integer | ❌ Não | Layer 3 VNI para VXLAN | `1` ou `10001` |

#### Parâmetros de Sessão/Firewall

| Parâmetro | Tipo | Obrigatório | Descrição | Exemplo |
|-----------|------|-------------|-----------|---------|
| `enable_connection_tracking_mode` | boolean | ❌ Não | Habilitar rastreamento de conexão | `true` ou `false` |
| `allow_session_reuse` | boolean | ❌ Não | Permitir reutilização de sessão | `true` ou `false` |
| `enable_ip_fragment_forwarding` | boolean | ❌ Não | Habilitar encaminhamento de fragmentos IP | `true` ou `false` |

---

### 2️⃣ AOS-CX REST API

#### Parâmetros Básicos (AOS-CX)

| Parâmetro | Tipo | Obrigatório | Descrição | Exemplo |
|-----------|------|-------------|-----------|---------|
| `name` | string | ✅ Sim | Nome da VRF | `"PROD-VRF"` |

#### Parâmetros de Route Target

| Parâmetro | Tipo | Obrigatório | Descrição | Exemplo |
|-----------|------|-------------|-----------|---------|
| `route_target` | object | ❌ Não | Configuração de Route Target | Ver estrutura abaixo |

**Estrutura de `route_target`:**

```json
{
  "primary_route_target": {
    "address_family": "evpn",           // "evpn" | "ipv4-unicast" | "ipv6-unicast"
    "route_mode": "import",             // "import" | "export" | "both"
    "ext_community": "65000:100"        // Opcional
  }
}
```

#### Parâmetros BGP

| Parâmetro | Tipo | Obrigatório | Descrição | Exemplo |
|-----------|------|-------------|-----------|---------|
| `bgp` | object | ❌ Não | Configurações BGP da VRF | Ver estrutura abaixo |

**Estrutura de `bgp`:**

```json
{
  "bestpath": true,                     // Habilitar best path selection
  "fast_external_fallover": true,       // Failover rápido para peers externos
  "trap_enable": false,                 // Habilitar SNMP traps para BGP
  "log_neighbor_changes": true,         // Logar mudanças de vizinhos
  "deterministic_med": true,            // MED determinístico
  "always_compare_med": true            // Sempre comparar MED
}
```

#### Parâmetros de Limites de Sessão

| Parâmetro | Tipo | Obrigatório | Descrição | Exemplo |
|-----------|------|-------------|-----------|---------|
| `max_sessions_mode` | string | ❌ Não | Modo de limite de sessões | `"unlimited"` ou `"limited"` |
| `max_sessions` | integer | ❌ Condicional | Máximo de sessões (se mode=limited) | `10000` |
| `max_cps_mode` | string | ❌ Não | Modo de limite de CPS | `"unlimited"` ou `"limited"` |
| `max_cps` | integer | ❌ Condicional | Máximo de CPS (se mode=limited) | `1000` |

**Nota**: `max_sessions` e `max_cps` são obrigatórios quando seus respectivos `*_mode` são definidos como `"limited"`.

### No-install option

When running the scripts you can opt out of automatic dependency installation with the `--no-install` flag. If you specify this flag the script will not attempt to install `jq`. In that case either `jq` or `python3` must already be available on the system.

### CLI and Wrapper Options

Os scripts `create-vrf-afc.sh` e `wrapper-create-vrf-afc.sh` expõem flags adicionais para definir limites de sessão e CPS diretamente a partir da linha de comando ou de parâmetros do Morpheus:

- `--max-sessions-mode [unlimited|limited]` ou `ARUBA_MAX_SESSIONS_MODE` (wrapper)
- `--max-cps-mode [unlimited|limited]` ou `ARUBA_MAX_CPS_MODE` (wrapper)
- `--max-sessions NUM` ou `ARUBA_MAX_SESSIONS` (wrapper)
- `--max-cps NUM` ou `ARUBA_MAX_CPS` (wrapper)

Estes flags são validados pelo script e injetados no payload enviado à API.

---

## 🔄 Mapeamento de Parâmetros Entre APIs

### Parâmetros que podem ser convertidos

| Conceito | Fabric Composer | AOS-CX | Conversão Possível? |
|----------|-----------------|--------|---------------------|
| **Nome** | `name` | `name` | ✅ Direto |
| **Route Distinguisher** | `route_distinguisher: "65000:100"` | Não suportado diretamente | ⚠️ Parcial (via route_target) |
| **Route Target Import** | `route_targets[].mode: "Import"` | `route_target.primary_route_target.route_mode: "import"` | ✅ Conversível |
| **Route Target Export** | `route_targets[].mode: "Export"` | `route_target.primary_route_target.route_mode: "export"` | ✅ Conversível |
| **Address Family (IPv4)** | `address_family: ["ipv4"]` | `route_target.primary_route_target.address_family: "ipv4-unicast"` | ✅ Conversível |
| **Address Family (IPv6)** | `address_family: ["ipv6"]` | `route_target.primary_route_target.address_family: "ipv6-unicast"` | ✅ Conversível |
| **Address Family (EVPN)** | `route_targets[].address_family: "EVPN"` | `route_target.primary_route_target.address_family: "evpn"` | ✅ Conversível |

---

## ❌ Parâmetros Exclusivos (Não Mapeáveis)

### Exclusivos do Fabric Composer (não disponíveis em AOS-CX)

| Parâmetro | Descrição | Uso Típico |
|-----------|-----------|------------|
| `fabric` | Nome do fabric (orquestração) | Obrigatório para AFC |
| `switches` | Lista de switches | Definir em quais switches criar a VRF |
| `l3_vni` | Layer 3 VNI para VXLAN | Ambientes EVPN/VXLAN |
| `description` | Descrição textual | Documentação |
| `enable_connection_tracking_mode` | Rastreamento de conexões | Firewall stateful |
| `allow_session_reuse` | Reutilização de sessão | Otimização de sessões |
| `enable_ip_fragment_forwarding` | Encaminhamento de fragmentos | Suporte a MTU menor |

### Exclusivos do AOS-CX (não disponíveis em Fabric Composer)

| Parâmetro | Descrição | Uso Típico |
|-----------|-----------|------------|
| `bgp.bestpath` | Best path selection | Otimização BGP |
| `bgp.fast_external_fallover` | Failover rápido | Alta disponibilidade |
| `bgp.trap_enable` | SNMP traps BGP | Monitoramento |
| `bgp.log_neighbor_changes` | Log de mudanças BGP | Troubleshooting |
| `bgp.deterministic_med` | MED determinístico | Roteamento consistente |
| `bgp.always_compare_med` | Comparação MED | Seleção de rota |
| `max_sessions_mode` | Modo de limite de sessões | Controle de recursos |
| `max_sessions` | Número máximo de sessões | Limitação de recursos |
| `max_cps_mode` | Modo de limite CPS | Controle de taxa |
| `max_cps` | Conexões por segundo | Proteção contra floods |

---

## 🎯 Proposta de Script Híbrido

### Opções de Design

#### **Opção 1: Modo Selecionável** (Recomendado)

```bash
./create-vrf-hybrid.sh --mode fabric-composer --name PROD-VRF ...
./create-vrf-hybrid.sh --mode aos-cx --switch cx10000 --name PROD-VRF ...
```

**Vantagens**:

- ✅ Clara separação de responsabilidades
- ✅ Parâmetros específicos por modo
- ✅ Validação adequada por API
- ✅ Mais fácil de manter

**Parâmetros por Modo**:

##### Modo: `fabric-composer`

```bash
Parâmetros Comuns:
  --name NAME                 Nome da VRF (obrigatório)
  --description DESC          Descrição

Parâmetros AFC:
  --fabric FABRIC             Nome do fabric (obrigatório)
  --switches "SW1,SW2"        Lista de switches
  --rd RD                     Route Distinguisher
  --rt-import RT              Route Target Import
  --rt-export RT              Route Target Export
  --af FAMILY                 Address Family
  --l3-vni VNI                Layer 3 VNI

Flags AFC:
  --enable-connection-tracking
  --allow-session-reuse
  --enable-ip-fragment-forwarding
```

##### Modo: `aos-cx`

```bash
Parâmetros Comuns:
  --name NAME                 Nome da VRF (obrigatório)

Parâmetros AOS-CX:
  --switch HOSTNAME           Switch hostname/IP (obrigatório)
  --rt-mode MODE              Route target mode (import/export/both)
  --rt-af FAMILY              Route target address family
  --rt-community COMMUNITY    Route target extended community

Parâmetros BGP:
  --bgp-bestpath              Habilitar BGP bestpath
  --bgp-fast-fallover         Habilitar fast external fallover
  --bgp-log-neighbor-changes  Logar mudanças de vizinhos
  --bgp-deterministic-med     MED determinístico
  --bgp-compare-med           Sempre comparar MED

Limites:
  --max-sessions NUM          Máximo de sessões
  --max-cps NUM               Máximo de CPS
```

#### **Opção 2: Auto-Detecção**

```bash
./create-vrf-hybrid.sh --name PROD-VRF --fabric default ...   # Detecta AFC
./create-vrf-hybrid.sh --name PROD-VRF --switch cx10000 ...   # Detecta AOS-CX
```

**Vantagens**:

- ✅ Interface mais simples
- ✅ Menos verboso

**Desvantagens**:

- ❌ Pode ser ambíguo
- ❌ Dificulta validação

---

## 💡 Recomendações

### Para Script Híbrido

1. **Use Opção 1 (Modo Selecionável)**
   - Mais claro e explícito
   - Melhor validação de parâmetros
   - Mais fácil de documentar

2. **Estrutura Sugerida**:

   ```bash
   ./create-vrf-hybrid.sh \
     --mode fabric-composer \    # ou --mode aos-cx
     --name PROD-VRF \
     --fabric default \
     [... parâmetros específicos do modo ...]
   ```

3. **Variáveis de Ambiente**:

   ```bash
   # .env para AFC
   FABRIC_COMPOSER_IP=172.31.8.99
   FABRIC_COMPOSER_USERNAME=admin
   FABRIC_COMPOSER_PASSWORD=Aruba123!

   # .env para AOS-CX
   AOSCX_SWITCH_IP=10.0.0.1
   AOSCX_USERNAME=admin
   AOSCX_PASSWORD=password
   AOSCX_API_VERSION=v10.15
   ```

4. **Funções Separadas**:
   - `create_vrf_afc()` - Para Fabric Composer
   - `create_vrf_aoscx()` - Para AOS-CX REST API
   - `validate_params_afc()` - Validação AFC
   - `validate_params_aoscx()` - Validação AOS-CX

---

## 📊 Resumo Executivo

### Parâmetros Totais

| API | Parâmetros Únicos | Parâmetros Comuns | Total |
|-----|-------------------|-------------------|-------|
| **Fabric Composer** | 11 | 1 (name) | 12 |
| **AOS-CX REST** | 10 | 1 (name) | 11 |

### Conversibilidade

- ✅ **Conversíveis**: 40% (name, route targets básicos, address family)
- ⚠️ **Parcialmente conversíveis**: 20% (route distinguisher)
- ❌ **Não conversíveis**: 40% (parâmetros exclusivos de cada API)

### Conclusão

Um script híbrido é **viável** mas requer:

- Dois conjuntos distintos de parâmetros
- Validação específica por modo
- Documentação clara das limitações
- Mapeamento explícito de parâmetros comuns

---

**Próximo Passo**: Você gostaria que eu implemente o script híbrido usando a **Opção 1 (Modo Selecionável)**?
