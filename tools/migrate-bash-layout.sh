#!/bin/bash
#############################################################################
# Script: migrate-bash-layout.sh
# Description: Reorganiza estrutura de scripts Bash e move core/commons.sh
#############################################################################
#
# Detalhes:
#  - Move core/commons.sh para lib/commons.sh
#  - Cria symlink na raiz: ./commons.sh -> lib/commons.sh (compatibilidade)
#  - Cria estrutura: scripts/aruba/{auth,vrf,backup,cli}, scripts/{hybrid,utilities}, examples/
#  - Move scripts conhecidos para a nova estrutura
#  - Cria symlinks na raiz para manter compatibilidade dos caminhos antigos
#  - Cria symlink commons.sh dentro dos diretórios de scripts (para source "$(dirname)/commons.sh")
#  - Atualiza referências em Markdown (core/commons -> lib/commons e caminhos de scripts)
#
# Uso:
#   tools/migrate-bash-layout.sh --dry-run   # mostra plano (padrão)
#   tools/migrate-bash-layout.sh --apply     # aplica mudanças
#
set -eo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

# Tentativa de carregar commons.sh (lib ou core) para logs padronizados
LOG_LOADED=0
if [[ -f "${REPO_ROOT}/lib/commons.sh" ]]; then
  # shellcheck disable=SC1091
  source "${REPO_ROOT}/lib/commons.sh" || true
  LOG_LOADED=1
elif [[ -f "${REPO_ROOT}/core/commons.sh" ]]; then
  # shellcheck disable=SC1091
  source "${REPO_ROOT}/core/commons.sh" || true
  LOG_LOADED=1
fi

# Fallback de logging mínimo caso commons.sh não esteja disponível
if [[ "${LOG_LOADED}" -eq 0 ]]; then
  RED='\033[0;31m'; YELLOW='\033[1;33m'; GREEN='\033[0;32m'; BLUE='\033[0;34m'; NC='\033[0m'
  log_info()    { echo -e "${BLUE}[INFO]${NC} $*"; }
  log_success() { echo -e "${GREEN}[OK]${NC} $*"; }
  log_warning() { echo -e "${YELLOW}[WARN]${NC} $*"; }
  log_error()   { echo -e "${RED}[ERROR]${NC} $*"; }
  log_section() { echo -e "\n${YELLOW}========== $* ==========${NC}\n"; }
  _log_func_enter() { :; }
  _log_func_exit_ok() { :; }
  _log_func_exit_fail() { :; }
fi

show_usage() {
  cat <<EOF
Uso: $(basename "$0") [--dry-run | --apply]

Opções:
  --dry-run  Mostra o plano de migração (padrão)
  --apply    Aplica mudanças no filesystem
EOF
}

APPLY=0
case "${1:-}" in
  --apply) APPLY=1 ;;
  --dry-run|"") APPLY=0 ;;
  -h|--help) show_usage; exit 0 ;;
  *) show_usage; exit 1 ;;
esac

require_cmd() {
  local c; for c in "$@"; do
    if ! command -v "$c" &>/dev/null; then
      log_error "Dependência ausente: $c"; exit 1
    fi
  done
}

require_cmd find sed ln mv mkdir realpath

ensure_dir() {
  local d="$1"
  if [[ ${APPLY} -eq 1 ]]; then
    mkdir -p "$d"
  fi
  log_success "Diretório garantido: $d"
}

ensure_executable() {
  local f="$1"
  if [[ -f "$f" && ${APPLY} -eq 1 ]]; then
    chmod +x "$f"
  fi
}

make_symlink() {
  local target="$1" linkpath="$2"
  if [[ ${APPLY} -eq 1 ]]; then
    rm -f "$linkpath" 2>/dev/null || true
    ln -s "$target" "$linkpath"
  fi
  log_success "Symlink: $linkpath -> $target"
}

relpath() {
  # realpath --relative-to wrapper com fallback simples
  local from="$1" to="$2"
  if realpath --help >/dev/null 2>&1; then
    realpath --relative-to="$from" "$to"
  else
    # Fallback: retorna caminho absoluto
    (cd "$from" && realpath "$to")
  fi
}

move_file() {
  local src="$1" dst="$2"
  if [[ ! -f "$src" ]]; then
    log_warning "Não encontrado (ignorando): $src"; return 0
  fi
  local dstdir
  dstdir="$(dirname "$dst")"; ensure_dir "$dstdir"
  if [[ ${APPLY} -eq 1 ]]; then
    if [[ -f "$dst" ]]; then
      log_warning "Destino já existe, mantendo: $dst"
    else
      mv "$src" "$dst"
      log_success "Movido: $src -> $dst"
    fi
  else
    log_info "Planejado mover: $src -> $dst"
  fi
}

ensure_commons_symlink() {
  local folder="$1"
  local commons_target="${REPO_ROOT}/lib/commons.sh"
  if [[ ! -f "$commons_target" ]]; then
    log_warning "lib/commons.sh não existe ainda; pulando symlink em $folder"
    return 0
  fi
  local rel
  rel="$(relpath "$folder" "$commons_target")"
  make_symlink "$rel" "$folder/commons.sh"
}

update_markdown_refs() {
  log_section "ATUALIZANDO REFERÊNCIAS EM .md"
  if [[ ${APPLY} -eq 1 ]]; then
    find "${REPO_ROOT}" -type f -name "*.md" \
      -exec sed -i \
        -e 's|core/commons|lib/commons|g' \
        -e 's|`create-vrf\.sh`|`scripts/aruba/vrf/create-vrf.sh`|g' \
        -e 's|`delete-vrf\.sh`|`scripts/aruba/vrf/delete-vrf.sh`|g' \
        -e 's|`aruba-auth\.sh`|`scripts/aruba/auth/aruba-auth.sh`|g' \
        -e 's|`install-aruba-cli\.sh`|`scripts/aruba/cli/install-aruba-cli.sh`|g' \
        -e 's|`create-aruba-vrf\.sh`|`scripts/hybrid/create-aruba-vrf.sh`|g' \
        -e 's|`create-vrf-hybrid\.sh`|`scripts/hybrid/create-vrf-hybrid.sh`|g' \
        -e 's|`example-create-vrf\.sh`|`examples/example-create-vrf.sh`|g' \
        -e 's|`example-vrf-workflow\.sh`|`examples/example-vrf-workflow.sh`|g' {} +
  else
    log_info "(dry-run) Atualizaria referências em arquivos .md"
  fi
}

log_section "MIGRAÇÃO DE ESTRUTURA (modo: $([[ ${APPLY} -eq 1 ]] && echo APPLY || echo DRY-RUN))"

# 1) Preparar lib/ e mover commons.sh
ensure_dir "${REPO_ROOT}/lib"
if [[ -f "${REPO_ROOT}/core/commons.sh" ]]; then
  move_file "${REPO_ROOT}/core/commons.sh" "${REPO_ROOT}/lib/commons.sh"
fi

# 1.1) Symlink na raiz para compatibilidade
if [[ -f "${REPO_ROOT}/lib/commons.sh" ]]; then
  rel_to_lib="$(relpath "${REPO_ROOT}" "${REPO_ROOT}/lib/commons.sh")"
  make_symlink "$rel_to_lib" "${REPO_ROOT}/commons.sh"
fi

# 2) Estrutura de diretórios
ensure_dir "${REPO_ROOT}/scripts/aruba/auth"
ensure_dir "${REPO_ROOT}/scripts/aruba/vrf"
ensure_dir "${REPO_ROOT}/scripts/aruba/backup"
ensure_dir "${REPO_ROOT}/scripts/aruba/cli"
ensure_dir "${REPO_ROOT}/scripts/hybrid"
ensure_dir "${REPO_ROOT}/scripts/utilities"
ensure_dir "${REPO_ROOT}/examples"

# 3) Mover scripts principais
declare -A MAP
MAP["${REPO_ROOT}/aruba-auth.sh"]="${REPO_ROOT}/scripts/aruba/auth/aruba-auth.sh"
MAP["${REPO_ROOT}/create-vrf.sh"]="${REPO_ROOT}/scripts/aruba/vrf/create-vrf.sh"
MAP["${REPO_ROOT}/install-aruba-cli.sh"]="${REPO_ROOT}/scripts/aruba/cli/install-aruba-cli.sh"
MAP["${REPO_ROOT}/create-vrf-hybrid.sh"]="${REPO_ROOT}/scripts/hybrid/create-vrf-hybrid.sh"
MAP["${REPO_ROOT}/create-aruba-vrf.sh"]="${REPO_ROOT}/scripts/hybrid/create-aruba-vrf.sh"
MAP["${REPO_ROOT}/example-create-vrf.sh"]="${REPO_ROOT}/examples/example-create-vrf.sh"
MAP["${REPO_ROOT}/example-vrf-workflow.sh"]="${REPO_ROOT}/examples/example-vrf-workflow.sh"

for src in "${!MAP[@]}"; do
  move_file "$src" "${MAP[$src]}"
  case "${MAP[$src]}" in
    */scripts/*/*/*.sh) ensure_executable "${MAP[$src]}" ;;
    */scripts/*/*.sh) ensure_executable "${MAP[$src]}" ;;
    */examples/*) ensure_executable "${MAP[$src]}" ;;
  esac
done

# 4) Symlinks de compatibilidade na raiz para scripts movidos
declare -A ROOT_LINKS
ROOT_LINKS["${REPO_ROOT}/aruba-auth.sh"]="scripts/aruba/auth/aruba-auth.sh"
ROOT_LINKS["${REPO_ROOT}/create-vrf.sh"]="scripts/aruba/vrf/create-vrf.sh"
ROOT_LINKS["${REPO_ROOT}/install-aruba-cli.sh"]="scripts/aruba/cli/install-aruba-cli.sh"
ROOT_LINKS["${REPO_ROOT}/create-vrf-hybrid.sh"]="scripts/hybrid/create-vrf-hybrid.sh"
ROOT_LINKS["${REPO_ROOT}/create-aruba-vrf.sh"]="scripts/hybrid/create-aruba-vrf.sh"
ROOT_LINKS["${REPO_ROOT}/example-create-vrf.sh"]="examples/example-create-vrf.sh"
ROOT_LINKS["${REPO_ROOT}/example-vrf-workflow.sh"]="examples/example-vrf-workflow.sh"

for link in "${!ROOT_LINKS[@]}"; do
  target_path="${REPO_ROOT}/${ROOT_LINKS[$link]}"
  if [[ -e "$target_path" ]]; then
    rel="$(relpath "$(dirname "$link")" "$target_path")"
    make_symlink "$rel" "$link"
  else
    log_warning "Destino do symlink não existe, ignorando: $target_path"
  fi
done

# 5) Symlink commons.sh dentro dos diretórios de scripts
ensure_commons_symlink "${REPO_ROOT}/scripts/aruba/auth"
ensure_commons_symlink "${REPO_ROOT}/scripts/aruba/vrf"
ensure_commons_symlink "${REPO_ROOT}/scripts/aruba/backup"
ensure_commons_symlink "${REPO_ROOT}/scripts/aruba/cli"
ensure_commons_symlink "${REPO_ROOT}/scripts/hybrid"
ensure_commons_symlink "${REPO_ROOT}/scripts/utilities"
ensure_commons_symlink "${REPO_ROOT}/examples"
# Opcional: suportar scripts auxiliares em ai-support
if [[ -d "${REPO_ROOT}/ai-support/scripts" ]]; then
  ensure_commons_symlink "${REPO_ROOT}/ai-support/scripts"
fi

# 6) Atualizar documentação
update_markdown_refs

log_section "RESUMO"
log_info "Estrutura final esperada (parcial):"
if command -v tree &>/dev/null; then
  tree -L 3 -I '.git|node_modules|.venv|__pycache__' --dirsfirst "${REPO_ROOT}" | sed -n '1,200p'
else
  (cd "${REPO_ROOT}" && find . -maxdepth 3 -type d | sort | sed -n '1,200p')
fi

log_success "Migração finalizada ($([[ ${APPLY} -eq 1 ]] && echo aplicada || echo dry-run))."
