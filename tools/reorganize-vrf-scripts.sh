#!/bin/bash
################################################################################
# Script: reorganize-vrf-scripts.sh
# Description: Reorganizes VRF scripts by separating AOS-CX and Fabric Composer implementations
################################################################################

set -eo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

# shellcheck disable=SC1091
source "${REPO_ROOT}/lib/commons.sh"

main() {
  _log_func_enter "main"

  log_section "REORGANIZING VRF SCRIPTS"

  # 1. Criar nova estrutura de diretórios
  log_info "Criando nova estrutura de diretórios..."
  mkdir -p "${REPO_ROOT}/scripts/aruba/vrf/aoscx"
  mkdir -p "${REPO_ROOT}/scripts/aruba/vrf/fabric-composer"

  # 2. Mover scripts de Fabric Composer
  log_section "MOVENDO SCRIPTS FABRIC COMPOSER"

  # create-aruba-vrf.sh (AFC puro) → fabric-composer/create-vrf-afc.sh
  if [[ -f "${REPO_ROOT}/scripts/hybrid/create-aruba-vrf.sh" ]]; then
    log_info "Movendo create-aruba-vrf.sh → scripts/aruba/vrf/fabric-composer/create-vrf-afc.sh"
    mv "${REPO_ROOT}/scripts/hybrid/create-aruba-vrf.sh" \
       "${REPO_ROOT}/scripts/aruba/vrf/fabric-composer/create-vrf-afc.sh"

    # Atualizar referência ao commons.sh (4 níveis acima)
    sed -i 's|source "$(cd "$(dirname "${BASH_SOURCE\[0\]}")/../../lib" \&\& pwd)/commons.sh"|source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../../lib" \&\& pwd)/commons.sh"|g' \
      "${REPO_ROOT}/scripts/aruba/vrf/fabric-composer/create-vrf-afc.sh"

    # Atualizar header do script
    sed -i 's|^# Script: create-aruba-vrf\.sh|# Script: create-vrf-afc.sh|' \
      "${REPO_ROOT}/scripts/aruba/vrf/fabric-composer/create-vrf-afc.sh"

    log_success "create-vrf-afc.sh movido e atualizado"
  fi

  # create-vrf-hybrid.sh (AFC + AOS-CX) → fabric-composer/create-vrf-hybrid.sh
  if [[ -f "${REPO_ROOT}/scripts/hybrid/create-vrf-hybrid.sh" ]]; then
    log_info "Movendo create-vrf-hybrid.sh → scripts/aruba/vrf/fabric-composer/create-vrf-hybrid.sh"
    mv "${REPO_ROOT}/scripts/hybrid/create-vrf-hybrid.sh" \
       "${REPO_ROOT}/scripts/aruba/vrf/fabric-composer/create-vrf-hybrid.sh"

    # Atualizar referência ao commons.sh (4 níveis acima)
    sed -i 's|source "$(cd "$(dirname "${BASH_SOURCE\[0\]}")/../../lib" \&\& pwd)/commons.sh"|source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../../lib" \&\& pwd)/commons.sh"|g' \
      "${REPO_ROOT}/scripts/aruba/vrf/fabric-composer/create-vrf-hybrid.sh"

    log_success "create-vrf-hybrid.sh movido e atualizado"
  fi

  # 3. Reorganizar script AOS-CX existente
  log_section "REORGANIZANDO SCRIPTS AOS-CX"

  if [[ -f "${REPO_ROOT}/scripts/aruba/vrf/create-vrf.sh" ]]; then
    log_info "Movendo create-vrf.sh → scripts/aruba/vrf/aoscx/create-vrf-aoscx.sh"
    mv "${REPO_ROOT}/scripts/aruba/vrf/create-vrf.sh" \
       "${REPO_ROOT}/scripts/aruba/vrf/aoscx/create-vrf-aoscx.sh"

    # Atualizar referência ao commons.sh (4 níveis acima)
    sed -i 's|source "$(cd "$(dirname "${BASH_SOURCE\[0\]}")/../../lib" \&\& pwd)/commons.sh"|source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../../lib" \&\& pwd)/commons.sh"|g' \
      "${REPO_ROOT}/scripts/aruba/vrf/aoscx/create-vrf-aoscx.sh"

    # Atualizar header do script
    sed -i 's|^# Script: create-vrf\.sh|# Script: create-vrf-aoscx.sh|' \
      "${REPO_ROOT}/scripts/aruba/vrf/aoscx/create-vrf-aoscx.sh"

    log_success "create-vrf-aoscx.sh movido e atualizado"
  fi

  # 4. Remover symlink duplicado de commons.sh em scripts/hybrid/
  log_section "REMOVENDO SYMLINKS DUPLICADOS"

  if [[ -L "${REPO_ROOT}/scripts/hybrid/commons.sh" ]]; then
    log_info "Removendo symlink: scripts/hybrid/commons.sh"
    rm -f "${REPO_ROOT}/scripts/hybrid/commons.sh"
    log_success "Symlink removido"
  fi

  # 5. Criar README para novos diretórios
  log_section "CRIANDO DOCUMENTAÇÃO"

  cat > "${REPO_ROOT}/scripts/aruba/vrf/README.md" << 'EOF'
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
EOF

  log_success "README.md criado em scripts/aruba/vrf/"

  # 6. Atualizar tests para novos caminhos
  log_section "ATUALIZANDO TESTES"

  # Atualizar test_create-vrf.bats
  if [[ -f "${REPO_ROOT}/tests/test_create-vrf.bats" ]]; then
    log_info "Atualizando tests/test_create-vrf.bats"
    sed -i 's|scripts/aruba/vrf/create-vrf.sh|scripts/aruba/vrf/aoscx/create-vrf-aoscx.sh|g' \
      "${REPO_ROOT}/tests/test_create-vrf.bats"
    log_success "test_create-vrf.bats atualizado"
  fi

  # Atualizar test_create-aruba-vrf.bats
  if [[ -f "${REPO_ROOT}/tests/test_create-aruba-vrf.bats" ]]; then
    log_info "Atualizando tests/test_create-aruba-vrf.bats"
    sed -i 's|scripts/hybrid/create-aruba-vrf.sh|scripts/aruba/vrf/fabric-composer/create-vrf-afc.sh|g' \
      "${REPO_ROOT}/tests/test_create-aruba-vrf.bats"

    # Atualizar também o nome no teste
    sed -i 's|create-aruba-vrf\.sh|create-vrf-afc.sh|g' \
      "${REPO_ROOT}/tests/test_create-aruba-vrf.bats"

    log_success "test_create-aruba-vrf.bats atualizado"
  fi

  # 7. Atualizar documentação do repositório
  log_section "ATUALIZANDO DOCUMENTAÇÃO"

  if [[ -f "${REPO_ROOT}/docs/VRF_FILES_LOCATION.md" ]]; then
    log_info "Atualizando docs/VRF_FILES_LOCATION.md"

    cat >> "${REPO_ROOT}/docs/VRF_FILES_LOCATION.md" << 'EOF'

## Atualização da Estrutura (2025-10-20)

### Nova Organização por Tipo de API

Os scripts VRF foram reorganizados para separar claramente as implementações:

**AOS-CX REST API (Direto)**
- `scripts/aruba/vrf/aoscx/create-vrf-aoscx.sh` - Gerenciamento direto de switches

**Fabric Composer API (Centralizado)**
- `scripts/aruba/vrf/fabric-composer/create-vrf-afc.sh` - AFC puro
- `scripts/aruba/vrf/fabric-composer/create-vrf-hybrid.sh` - AFC + AOS-CX

### Migração de Caminhos

| Script Antigo | Novo Caminho | Tipo |
|---------------|--------------|------|
| `scripts/aruba/vrf/create-vrf.sh` | `scripts/aruba/vrf/aoscx/create-vrf-aoscx.sh` | AOS-CX |
| `scripts/hybrid/create-aruba-vrf.sh` | `scripts/aruba/vrf/fabric-composer/create-vrf-afc.sh` | AFC |
| `scripts/hybrid/create-vrf-hybrid.sh` | `scripts/aruba/vrf/fabric-composer/create-vrf-hybrid.sh` | Híbrido |

EOF

    log_success "VRF_FILES_LOCATION.md atualizado"
  fi

  # 8. Verificar se scripts/hybrid/ está vazio e remover se necessário
  log_section "LIMPEZA"

  if [[ -d "${REPO_ROOT}/scripts/hybrid" ]]; then
    # Contar arquivos (exceto .gitkeep)
    local file_count
    file_count=$(find "${REPO_ROOT}/scripts/hybrid" -type f ! -name ".gitkeep" | wc -l)

    if [[ ${file_count} -eq 0 ]]; then
      log_info "Diretório scripts/hybrid/ está vazio, removendo..."
      rm -rf "${REPO_ROOT}/scripts/hybrid"
      log_success "scripts/hybrid/ removido"
    else
      log_info "scripts/hybrid/ ainda contém arquivos, mantendo diretório"
    fi
  fi

  # 9. Resumo final
  log_section "RESUMO DA REORGANIZAÇÃO"

  log_success "Reorganização concluída!"
  echo ""
  echo "Nova estrutura:"
  echo ""
  echo "scripts/aruba/vrf/"
  echo "├── aoscx/"
  echo "│   └── create-vrf-aoscx.sh      (AOS-CX REST API direto)"
  echo "└── fabric-composer/"
  echo "    ├── create-vrf-afc.sh        (Fabric Composer puro)"
  echo "    └── create-vrf-hybrid.sh     (AFC + AOS-CX híbrido)"
  echo ""
  echo "Mudanças aplicadas:"
  echo "  ✓ Scripts movidos e renomeados"
  echo "  ✓ Referências ao commons.sh atualizadas"
  echo "  ✓ Headers dos scripts atualizados"
  echo "  ✓ Testes BATS atualizados"
  echo "  ✓ Documentação criada/atualizada"
  echo "  ✓ Symlinks duplicados removidos"
  echo ""

  _log_func_exit_ok "main"
  return 0
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi
