# Guia Rápido - Script Híbrido de Criação de VRF

## 🎯 Visão Geral

O script `scripts/hybrid/create-vrf-hybrid.sh` suporta **dois modos de operação**:

1. **Fabric Composer** - API centralizada (SDN)
2. **AOS-CX** - API REST direta no switch

---

## 🚀 Uso Rápido

### Modo 1: Fabric Composer

```bash
./create-vrf-hybrid.sh \
  --mode fabric-composer \
  --name PROD-VRF \
  --fabric default \
  --rd 65000:100 \
  --rt-import "65000:100" \
  --rt-export "65000:100"
```

### Modo 2: AOS-CX

```bash
./create-vrf-hybrid.sh \
  --mode aos-cx \
  --switch cx10000.local \
  --name PROD-VRF \
  --bgp-bestpath \
  --max-sessions 10000
```

---

## 📋 Parâmetros por Modo

### Parâmetros Comuns (ambos os modos)

| Parâmetro | Descrição | Exemplo |
|-----------|-----------|---------|
| `--mode` | Modo de operação (obrigatório) | `fabric-composer` ou `aos-cx` |
| `--name` | Nome da VRF (obrigatório) | `PROD-VRF` |
| `--description` | Descrição | `"VRF de Produção"` |
| `--dry-run` | Validar sem criar | - |
| `--env-file` | Arquivo de ambiente | `.env` |

### Parâmetros Fabric Composer

| Parâmetro | Descrição | Exemplo |
|-----------|-----------|---------|
| `--fabric` | Nome do fabric (obrigatório) | `default` |
| `--switches` | Lista de switches | `"CX10000,CX10001"` |
| `--rd` | Route Distinguisher | `65000:100` |
| `--rt-import` | Route Target Import | `"65000:100,65000:200"` |
| `--rt-export` | Route Target Export | `"65000:100"` |
| `--af` | Address Family | `ipv4` ou `"ipv4,ipv6"` |
| `--l3-vni` | Layer 3 VNI | `10001` |
| `--enable-connection-tracking` | Habilitar connection tracking | - |
| `--allow-session-reuse` | Permitir reutilização de sessão | - |
| `--enable-ip-fragment-forwarding` | Encaminhamento de fragmentos | - |

### Parâmetros AOS-CX

| Parâmetro | Descrição | Exemplo |
|-----------|-----------|---------|
| `--switch` | Hostname/IP do switch (obrigatório) | `cx10000.local` |
| `--rt-mode` | Modo de route target | `import`, `export`, ou `both` |
| `--rt-af` | Address family do route target | `evpn`, `ipv4-unicast`, `ipv6-unicast` |
| `--rt-community` | Extended community | `65000:100` |
| `--bgp-bestpath` | Habilitar BGP bestpath | - |
| `--bgp-fast-fallover` | Fast external fallover | - |
| `--bgp-trap-enable` | Habilitar SNMP traps BGP | - |
| `--bgp-log-neighbor-changes` | Logar mudanças de vizinhos | - |
| `--bgp-deterministic-med` | MED determinístico | - |
| `--bgp-compare-med` | Sempre comparar MED | - |
| `--max-sessions` | Máximo de sessões | `10000` |
| `--max-cps` | Máximo de CPS | `1000` |

---

## 📁 Configuração (.env)

### Para Fabric Composer

```bash
FABRIC_COMPOSER_IP=172.31.8.99
FABRIC_COMPOSER_USERNAME=admin
FABRIC_COMPOSER_PASSWORD=Aruba123!
FABRIC_COMPOSER_PORT=443
FABRIC_COMPOSER_PROTOCOL=https
```

### Para AOS-CX

```bash
AOSCX_SWITCH_IP=10.0.0.1
AOSCX_USERNAME=admin
AOSCX_PASSWORD=password
AOSCX_PORT=443
AOSCX_PROTOCOL=https
AOSCX_API_VERSION=v10.15
```

---

## 💡 Exemplos Completos

### Exemplo 1: Fabric Composer com VXLAN

```bash
./create-vrf-hybrid.sh \
  --mode fabric-composer \
  --env-file .env \
  --name DATACENTER-VRF \
  --fabric dc1-fabric \
  --switches "CX10000,CX10001,CX10002" \
  --rd 65000:100 \
  --rt-import "65000:100,65000:200" \
  --rt-export "65000:100" \
  --af "ipv4,ipv6" \
  --l3-vni 10001 \
  --description "VRF do Datacenter"
```

### Exemplo 2: Fabric Composer com Firewall

```bash
./create-vrf-hybrid.sh \
  --mode fabric-composer \
  --env-file .env \
  --name GUEST-VRF \
  --fabric default \
  --enable-connection-tracking \
  --allow-session-reuse \
  --description "VRF de Convidados com Firewall"
```

### Exemplo 3: AOS-CX com BGP Completo

```bash
./create-vrf-hybrid.sh \
  --mode aos-cx \
  --switch cx10000.cec.dev.br \
  --name BGP-VRF \
  --rt-mode both \
  --rt-af evpn \
  --rt-community "65000:100" \
  --bgp-bestpath \
  --bgp-fast-fallover \
  --bgp-log-neighbor-changes \
  --bgp-deterministic-med \
  --bgp-compare-med \
  --description "VRF com BGP otimizado"
```

### Exemplo 4: AOS-CX com Limites

```bash
./create-vrf-hybrid.sh \
  --mode aos-cx \
  --switch cx10000.local \
  --name LIMITED-VRF \
  --max-sessions 5000 \
  --max-cps 500 \
  --description "VRF com limites de recursos"
```

### Exemplo 5: Dry-run (ambos os modos)

```bash
# Fabric Composer
./create-vrf-hybrid.sh \
  --mode fabric-composer \
  --name TEST-VRF \
  --fabric default \
  --dry-run

# AOS-CX
./create-vrf-hybrid.sh \
  --mode aos-cx \
  --switch cx10000.local \
  --name TEST-VRF \
  --dry-run
```

---

## 🔄 Comparação com Scripts Anteriores

| Recurso | create-aruba-vrf.sh | create-vrf-hybrid.sh |
|---------|---------------------|----------------------|
| **API** | Apenas Fabric Composer | Fabric Composer + AOS-CX |
| **Modos** | 1 modo | 2 modos selecionáveis |
| **Switches** | ❌ Não suportado | ✅ Suportado (AFC) |
| **L3 VNI** | ❌ Não suportado | ✅ Suportado (AFC) |
| **BGP Settings** | ❌ Não suportado | ✅ Suportado (AOS-CX) |
| **Session Limits** | ❌ Não suportado | ✅ Suportado (AOS-CX) |
| **Apply Step** | ✅ Sim (AFC) | ✅ Sim (AFC) |

---

## 🧪 Testes

### Teste 1: Validação (Dry-run)

```bash
# Fabric Composer
./create-vrf-hybrid.sh \
  --mode fabric-composer \
  --env-file .env \
  --name TEST-VRF-01 \
  --fabric default \
  --dry-run

# AOS-CX
./create-vrf-hybrid.sh \
  --mode aos-cx \
  --switch cx10000.local \
  --name TEST-VRF-01 \
  --dry-run
```

### Teste 2: Criação Simples

```bash
# Fabric Composer
./create-vrf-hybrid.sh \
  --mode fabric-composer \
  --env-file .env \
  --name TEST-VRF-02 \
  --fabric default

# AOS-CX
./create-vrf-hybrid.sh \
  --mode aos-cx \
  --switch cx10000.local \
  --name TEST-VRF-02
```

---

## ❌ Troubleshooting

### Erro: "Operation mode is required"

**Solução**: Sempre especifique `--mode`:

```bash
./create-vrf-hybrid.sh --mode fabric-composer --name MY-VRF ...
```

### Erro: "Fabric name is required for AFC mode"

**Solução**: Em modo Fabric Composer, `--fabric` é obrigatório:

```bash
./create-vrf-hybrid.sh --mode fabric-composer --fabric default ...
```

### Erro: "Switch hostname/IP is required for AOS-CX mode"

**Solução**: Em modo AOS-CX, `--switch` é obrigatório:

```bash
./create-vrf-hybrid.sh --mode aos-cx --switch cx10000.local ...
```

### Erro: "Authentication failed"

**Solução**: Verifique credenciais no `.env`:

```bash
# Para AFC
FABRIC_COMPOSER_IP=172.31.8.99
FABRIC_COMPOSER_USERNAME=admin
FABRIC_COMPOSER_PASSWORD=Aruba123!

# Para AOS-CX (se usando env vars)
AOSCX_SWITCH_IP=10.0.0.1
AOSCX_USERNAME=admin
AOSCX_PASSWORD=password
```

---

## 📚 Documentação Adicional

- **Comparação de Parâmetros**: `VRF_PARAMETERS_COMPARISON.md`
- **Comparação de Métodos**: `VRF_METHODS_COMPARISON.md`
- **Guia AFC**: `QUICKSTART_VRF_AFC.md`

---

## 🎯 Quando Usar Cada Modo?

### Use Fabric Composer quando

- ✅ Gerenciar múltiplos switches
- ✅ Usar VXLAN/EVPN
- ✅ Precisar de orquestração centralizada
- ✅ Configurar L3 VNI
- ✅ Aplicar VRF em múltiplos devices

### Use AOS-CX quando

- ✅ Configurar switch individual
- ✅ Precisar de parâmetros BGP específicos
- ✅ Configurar limites de sessão/CPS
- ✅ Não ter Fabric Composer disponível
- ✅ Integração direta com Morpheus

---

**Última Atualização**: 19 de Outubro de 2025
**Versão**: 1.0 (Híbrido)
**Autor**: GitHub Copilot
