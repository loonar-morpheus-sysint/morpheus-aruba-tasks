# Comparação: 3 Abordagens para Criação de VRF no Aruba

## 📊 Visão Geral

Este documento compara **3 métodos diferentes** para criar VRFs em ambientes Aruba:

1. ✅ **Script Atual** (`scripts/hybrid/create-aruba-vrf.sh`) - Fabric Composer API v1
2. 📝 **Script Alternativo** - Fabric Composer com `/sites/default/vrfs`
3. 🔧 **API AOS-CX** - REST API direta no switch

---

## 🎯 Método 1: Script Atual (create-aruba-vrf.sh)

### Características

- **API**: Fabric Composer REST API v1
- **Endpoint**: `/api/v1/sites/default/vrfs`
- **Autenticação**: Bearer Token (JWT)
- **Escopo**: Orquestração centralizada (múltiplos switches)
- **Apply Step**: ✅ Sim (automático)

### Uso

```bash
./scripts/hybrid/create-aruba-vrf.sh \
  --env-file .env \
  --name PROD-VRF \
  --fabric default \
  --rd 65000:100 \
  --rt-import "65000:100" \
  --rt-export "65000:100" \
  --af ipv4
```

### Payload JSON

```json
{
  "name": "PROD-VRF",
  "fabric": "default",
  "route-distinguisher": "65000:100",
  "route-target-import": ["65000:100"],
  "route-target-export": ["65000:100"],
  "address-family": ["ipv4"]
}
```

### Vantagens

- ✅ Script robusto com validações completas
- ✅ Logging estruturado (commons.sh)
- ✅ Gerenciamento automático de token
- ✅ Apply step automático
- ✅ Modo dry-run
- ✅ Modo interativo
- ✅ Suporte a .env
- ✅ Documentação completa

### Desvantagens

- ❌ Requer Fabric Composer instalado
- ❌ Não suporta parâmetros específicos AOS-CX (BGP, sessions, etc.)

---

## 🎯 Método 2: Script Alternativo (com switches e L3 VNI)

### Características do Método 2

- **API**: Fabric Composer REST API v1
- **Endpoint**: `/api/v1/sites/default/vrfs`
- **Autenticação**: Headers `X-Auth-Username` / `X-Auth-Password`
- **Escopo**: Orquestração com parâmetros VXLAN/EVPN
- **Apply Step**: ✅ Sim (manual)

### Payload JSON (Método 2)

```json
{
  "name": "TesteLonnar1",
  "description": "Teste de criação de VRF",
  "switches": ["CX10000"],
  "enable_connection_tracking_mode": true,
  "allow_session_reuse": false,
  "enable_ip_fragment_forwarding": false,
  "route_distinguisher": "loopback0",
  "l3_vni": 1,
  "route_targets": [
    {
      "mode": "Import",
      "ext_community": "10.10.10.1:101",
      "address_family": "IPv4 Unicast"
    }
  ]
}
```

### Vantagens do Método 2

- ✅ Suporta lista de switches
- ✅ Suporta L3 VNI (VXLAN)
- ✅ Connection tracking mode
- ✅ Flags específicas de sessão

### Desvantagens do Método 2

- ❌ Autenticação menos segura (headers)
- ❌ Sem gerenciamento de token
- ❌ Sem validações
- ❌ Hardcoded

---

## 🎯 Método 3: API AOS-CX REST (Switch Direto)

### Características do Método 3

- **API**: AOS-CX REST API v10.15
- **Endpoint**: `/api/v10.15/system/vrfs`
- **Host**: Switch individual (ex: `cx10000.cec.dev.br`)
- **Escopo**: Device-level (um switch por vez)
- **Apply Step**: ❌ Não (configuração direta)

### Payload JSON (Método 3)

```json
{
  "name": "<%=customOptions.vrf_name%>",
  "route_target": {
    "primary_route_target": {
      "address_family": "evpn",
      "route_mode": "import"
    }
  },
  "bgp": {
    "bestpath": true,
    "fast_external_fallover": true,
    "trap_enable": false,
    "log_neighbor_changes": true,
    "deterministic_med": true,
    "always_compare_med": true
  },
  "max_sessions_mode": "unlimited",
  "max_cps_mode": "unlimited",
  "max_sessions": 10000,
  "max_cps": 1000
}
```

### Uso (Morpheus Task)

```bash
curl -X POST "https://cx10000.cec.dev.br/api/v10.15/system/vrfs" \
  -H "Content-Type: application/json" \
  -d '{...payload...}'
```

### Vantagens do Método 3

- ✅ Configuração direta no switch
- ✅ Parâmetros BGP completos
- ✅ Limites de sessão/CPS configuráveis
- ✅ Ideal para Morpheus templates
- ✅ Não requer Fabric Composer

### Desvantagens do Método 3

- ❌ Um switch por vez (sem orquestração)
- ❌ Sem centralização
- ❌ Requer acesso direto ao switch
- ❌ Versão da API específica (v10.15)

---

## 📋 Tabela Comparativa

| Característica | Script Atual | Script Alt. | AOS-CX REST |
|----------------|--------------|-------------|-------------|
| **API** | Fabric Composer v1 | Fabric Composer v1 | AOS-CX v10.15 |
| **Endpoint** | `/api/v1/sites/default/vrfs` | `/api/v1/sites/default/vrfs` | `/api/v10.15/system/vrfs` |
| **Host** | Fabric Composer | Fabric Composer | Switch Individual |
| **Autenticação** | Bearer Token (JWT) | Headers | Depends on switch |
| **Apply Step** | ✅ Automático | ✅ Manual | ❌ N/A |
| **Orquestração** | ✅ Múltiplos switches | ✅ Múltiplos switches | ❌ Um switch |
| **L3 VNI** | ❌ Não | ✅ Sim | ❌ Não |
| **Switches List** | ❌ Não | ✅ Sim | ❌ N/A |
| **BGP Settings** | ❌ Não | ❌ Não | ✅ Sim |
| **Session Limits** | ❌ Não | ❌ Não | ✅ Sim |
| **Logging** | ✅ Estruturado | ❌ Básico | ❌ N/A |
| **Validações** | ✅ Completas | ❌ Mínimas | ❌ N/A |
| **Dry-run** | ✅ Sim | ❌ Não | ❌ N/A |
| **Modo Interativo** | ✅ Sim | ❌ Não | ❌ N/A |
| **Morpheus** | ✅ Compatível | ✅ Compatível | ✅ Ideal |

---

## 🎯 Quando Usar Cada Método?

### Use Método 1 (Script Atual) quando

- ✅ Você tem Fabric Composer implantado
- ✅ Precisa de orquestração centralizada
- ✅ Quer validações e logging robustos
- ✅ Precisa de modo interativo ou dry-run
- ✅ Quer gerenciamento automático de token
- ✅ Usa CI/CD pipelines

### Use Método 2 (Script Alternativo) quando

- ✅ Precisa de parâmetros VXLAN/EVPN específicos
- ✅ Precisa configurar lista de switches
- ✅ Precisa de L3 VNI
- ✅ Quer connection tracking mode
- ✅ Usa Fabric Composer mas precisa de parâmetros avançados

### Use Método 3 (AOS-CX REST) quando

- ✅ Não tem Fabric Composer
- ✅ Configura switch individual
- ✅ Precisa de parâmetros BGP específicos
- ✅ Precisa configurar limites de sessão/CPS
- ✅ Integra com Morpheus Tasks/Workflows
- ✅ Quer configuração direta sem intermediários

---

## 🔄 Migração Entre Métodos

### De Método 2 → Método 1 (Atual)

**Limitações**:

- Parâmetros não suportados: `switches`, `l3_vni`, `connection_tracking`, etc.

**Solução**:

- Use Método 1 para criação básica
- Configure parâmetros avançados via UI do Fabric Composer
- Ou combine ambos os métodos

### De Método 3 → Método 1

**Cenário**: Migração de configuração direta para SDN

**Passos**:

1. Inventariar VRFs existentes via AOS-CX API
2. Extrair parâmetros (RD, RT, AF)
3. Recriar via Fabric Composer (Método 1)
4. Validar configuração

**Limitações**:

- Parâmetros BGP não migram automaticamente
- Session limits precisam ser reconfigurados

---

## 📚 Referências

### Fabric Composer (Métodos 1 e 2)

- [AFC API Getting Started](https://developer.arubanetworks.com/afc/docs/getting-started-with-the-afc-api)
- [VRF Documentation](https://arubanetworking.hpe.com/techdocs/AFC/700/Content/afc70olh/add-vrf.htm)
- [Ansible Collection](https://github.com/aruba/hpeanfc-ansible-collection)

### AOS-CX REST API (Método 3)

- [AOS-CX REST API Guide](https://developer.arubanetworks.com/aruba-aoscx/docs)
- [VRF Configuration](https://developer.arubanetworks.com/aruba-aoscx/reference/get_system-vrfs)

---

## 💡 Recomendação Final

**Para este projeto (morpheus-aruba-tasks)**:

✅ **Use Método 1** (script atual `scripts/hybrid/create-aruba-vrf.sh`)

**Razões**:

- ✅ Fabric Composer está disponível (172.31.8.99)
- ✅ Necessidade de orquestração centralizada
- ✅ Integração com Morpheus já preparada
- ✅ Logging e validações robustas
- ✅ Fácil manutenção e evolução

**Futuro**:

- Considerar adicionar parâmetros do Método 2 (switches, l3_vni)
- Criar script separado para AOS-CX direto (Método 3) se necessário
- Documentar migração entre métodos

---

**Última Atualização**: 19 de Outubro de 2025
**Autor**: GitHub Copilot
**Versão**: 1.0
