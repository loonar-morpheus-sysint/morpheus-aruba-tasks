# VRF Scripts - Aruba

Scripts para criação e gerenciamento de VRFs (Virtual Routing and Forwarding) em dispositivos Aruba.

## Estrutura

### `aoscx/` - Scripts AOS-CX REST API

Scripts que interagem diretamente com switches AOS-CX via REST API.

- **create-vrf-aoscx.sh** - Criação de VRF em switches AOS-CX individuais

**Quando usar:**

- Gerenciamento direto de switches AOS-CX específicos
- Ambientes sem Fabric Composer
- Configurações granulares por switch

### `fabric-composer/` - Scripts Fabric Composer API

Scripts que interagem com HPE Aruba Networking Fabric Composer (AFC) para gerenciamento centralizado.

- **create-vrf-afc.sh** - Criação de VRF via Fabric Composer (AFC puro)
- **create-vrf-hybrid.sh** - Script híbrido que suporta AMBOS AFC e AOS-CX

**Quando usar:**

- Gerenciamento centralizado via Fabric Composer
- Provisionamento em múltiplos switches
- Workflows orquestrados (AFC)
- Quando precisar de flexibilidade entre AFC e AOS-CX direto

## Comparação

| Característica | AOS-CX REST API | Fabric Composer API |
|----------------|-----------------|---------------------|
| **Escopo** | Switch individual | Múltiplos switches/fabric |
| **Gerenciamento** | Descentralizado | Centralizado (SDN) |
| **Complexidade** | Simples/direto | Orquestrado |
| **Use Case** | Config específica | Provisionamento em escala |

## Exemplos de Uso

### AOS-CX Direto

```bash
./aoscx/create-vrf-aoscx.sh \
  --switch cx10000.local \
  --name PROD-VRF \
  --bgp-bestpath
```

### Fabric Composer

```bash
./fabric-composer/create-vrf-afc.sh \
  --name PROD-VRF \
  --fabric dc1-fabric \
  --rd 65000:100 \
  --switches "CX10000,CX10001"
```

### Híbrido (AFC ou AOS-CX)

```bash
# Modo AFC
./fabric-composer/create-vrf-hybrid.sh \
  --mode fabric-composer \
  --name PROD-VRF \
  --fabric dc1-fabric

# Modo AOS-CX
./fabric-composer/create-vrf-hybrid.sh \
  --mode aos-cx \
  --switch cx10000.local \
  --name PROD-VRF
```

## Dependências

Todos os scripts requerem:

- `curl` - Cliente HTTP
- `jq` - Processador JSON
- `lib/commons.sh` - Biblioteca comum (logging, etc)

## Variáveis de Ambiente

### Para AOS-CX

```bash
AOSCX_SWITCH_IP=cx10000.local
AOSCX_USERNAME=admin
AOSCX_PASSWORD=password
AOSCX_PORT=443
AOSCX_PROTOCOL=https
```

### Para Fabric Composer

```bash
FABRIC_COMPOSER_IP=afc.example.com
FABRIC_COMPOSER_USERNAME=admin
FABRIC_COMPOSER_PASSWORD=password
FABRIC_COMPOSER_PORT=443
FABRIC_COMPOSER_PROTOCOL=https
```

## Referências

- [AOS-CX REST API Guide](https://developer.arubanetworks.com/aoscx/docs)
- [Fabric Composer API Guide](https://developer.arubanetworks.com/afc/docs)
- [VRF Configuration Best Practices](https://arubanetworking.hpe.com/techdocs/)
