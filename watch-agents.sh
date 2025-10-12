#!/bin/bash
################################################################################
# Script: watch-agents.sh
# Description: Monitora mudanças no AGENTS.md e regenera instruções do Copilot
################################################################################
#
# DESCRIÇÃO:
#   Monitora o arquivo AGENTS.md usando inotifywait e executa automaticamente
#   o script generate-copilot-instructions.sh sempre que o arquivo for
#   modificado, salvo ou fechado após edição.
#
#   Este script roda em background e foi projetado para ser iniciado
#   automaticamente no devcontainer.
#
# DEPENDÊNCIAS:
#   - inotify-tools: Para monitoramento de mudanças em arquivos
#   - generate-copilot-instructions.sh: Script que processa o AGENTS.md
#
# USO:
#   ./watch-agents.sh                    # Roda em foreground (modo debug)
#   ./watch-agents.sh --background       # Roda em background
#   ./watch-agents.sh --stop             # Para processo em background
#
# VARIÁVEIS DE AMBIENTE:
#   WATCH_AGENTS_DEBOUNCE: Tempo em segundos para debounce (padrão: 2)
#
################################################################################

# Carrega biblioteca comum
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck disable=SC1091
if [[ -f "${SCRIPT_DIR}/commons.sh" ]]; then
  source "${SCRIPT_DIR}/commons.sh"

  # Definir funções de rastreamento de função (não existem no commons.sh)
  _log_func_enter() {
    log_debug "→ Entrando em função: $1"
  }

  _log_func_exit_ok() {
    log_debug "← Saindo de função: $1 (sucesso)"
  }

  _log_func_exit_fail() {
    log_debug "← Saindo de função: $1 (falha: código ${2:-1})"
  }

  # Adicionar função log_success e log_section se não existirem
  if ! command -v log_success &> /dev/null; then
    log_success() {
      log_info "✅ $*"
    }
  fi

  if ! command -v log_section &> /dev/null; then
    log_section() {
      echo ""
      log_info "═══ $* ═══"
      echo ""
    }
  fi
else
  # Fallback: definir funções de log vazias se commons.sh não estiver disponível
  _log_func_enter() { :; }
  _log_func_exit_ok() { :; }
  _log_func_exit_fail() { :; }
  log_info() { echo "[INFO] $*"; }
  log_error() { echo "[ERROR] $*" >&2; }
  log_warning() { echo "[WARNING] $*"; }
  log_warn() { echo "[WARN] $*"; }
  log_success() { echo "[SUCCESS] $*"; }
  log_section() { echo "=== $* ==="; }
  log_debug() { :; }  # Debug silencioso por padrão
fi

################################################################################
# Configurações
################################################################################

ARQUIVO_MONITORADO="AGENTS.md"
SCRIPT_GERADOR="generate-copilot-instructions.sh"
PID_FILE="/tmp/watch-agents.pid"
LOG_FILE="${SCRIPT_DIR}/logs/watch-agents.log"
DEBOUNCE_TIME="${WATCH_AGENTS_DEBOUNCE:-2}"  # segundos de espera após mudança

################################################################################
# Funções
################################################################################

# Verifica se o processo watcher já está rodando
check_running() {
  _log_func_enter "check_running"

  if [[ -f "${PID_FILE}" ]]; then
    local pid
    pid=$(cat "${PID_FILE}")

    if ps -p "${pid}" > /dev/null 2>&1; then
      log_info "Watcher já está rodando (PID: ${pid})"
      _log_func_exit_ok "check_running"
      return 0
    else
      log_warning "PID file existe mas processo não está rodando, limpando..."
      rm -f "${PID_FILE}"
      _log_func_exit_fail "check_running" "1"
      return 1
    fi
  fi

  _log_func_exit_fail "check_running" "1"
  return 1
}

# Para o processo watcher
stop_watcher() {
  _log_func_enter "stop_watcher"

  if [[ ! -f "${PID_FILE}" ]]; then
    log_error "Watcher não está rodando (PID file não encontrado)"
    _log_func_exit_fail "stop_watcher" "1"
    return 1
  fi

  local pid
  pid=$(cat "${PID_FILE}")

  if ps -p "${pid}" > /dev/null 2>&1; then
    log_info "Parando watcher (PID: ${pid})..."
    kill "${pid}"
    rm -f "${PID_FILE}"
    log_success "Watcher parado com sucesso"
    _log_func_exit_ok "stop_watcher"
    return 0
  else
    log_error "Processo ${pid} não está rodando"
    rm -f "${PID_FILE}"
    _log_func_exit_fail "stop_watcher" "1"
    return 1
  fi
}

# Mostra o status do watcher
show_status() {
  _log_func_enter "show_status"

  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "📊 Status do AGENTS.md Watcher"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

  if check_running; then
    local pid
    pid=$(cat "${PID_FILE}")
    echo "Status: ✅ Rodando"
    echo "PID: ${pid}"
    echo "Arquivo monitorado: ${ARQUIVO_MONITORADO}"
    echo "Log: ${LOG_FILE}"
  else
    echo "Status: ❌ Parado"
  fi

  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

  _log_func_exit_ok "show_status"
  return 0
}

# Valida dependências
check_dependencies() {
  _log_func_enter "check_dependencies"
  local all_ok=0

  # Verifica inotifywait
  if ! command -v inotifywait &> /dev/null; then
    log_error "inotifywait não encontrado. Instale com: sudo apt-get install inotify-tools"
    all_ok=1
  fi

  # Verifica se script gerador existe
  if [[ ! -f "${SCRIPT_DIR}/${SCRIPT_GERADOR}" ]]; then
    log_error "Script ${SCRIPT_GERADOR} não encontrado em ${SCRIPT_DIR}"
    all_ok=1
  fi

  # Verifica se arquivo monitorado existe
  if [[ ! -f "${SCRIPT_DIR}/${ARQUIVO_MONITORADO}" ]]; then
    log_error "Arquivo ${ARQUIVO_MONITORADO} não encontrado em ${SCRIPT_DIR}"
    all_ok=1
  fi

  if [[ ${all_ok} -eq 0 ]]; then
    _log_func_exit_ok "check_dependencies"
    return 0
  else
    _log_func_exit_fail "check_dependencies" "1"
    return 1
  fi
}

# Executa o script gerador
run_generator() {
  _log_func_enter "run_generator"

  log_section "Executando gerador de instruções"
  log_info "Arquivo modificado detectado: ${ARQUIVO_MONITORADO}"
  log_info "Aguardando ${DEBOUNCE_TIME}s para estabilizar..."

  sleep "${DEBOUNCE_TIME}"

  log_info "Executando ${SCRIPT_GERADOR}..."

  cd "${SCRIPT_DIR}" || {
    log_error "Falha ao mudar para diretório ${SCRIPT_DIR}"
    _log_func_exit_fail "run_generator" "1"
    return 1
  }

  if bash "${SCRIPT_GERADOR}"; then
    log_success "Instruções do Copilot regeneradas com sucesso!"
    _log_func_exit_ok "run_generator"
    return 0
  else
    log_error "Falha ao executar ${SCRIPT_GERADOR}"
    _log_func_exit_fail "run_generator" "1"
    return 1
  fi
}

# Inicia monitoramento
start_monitoring() {
  _log_func_enter "start_monitoring"

  log_section "Iniciando monitoramento de ${ARQUIVO_MONITORADO}"
  log_info "Diretório: ${SCRIPT_DIR}"
  log_info "Eventos monitorados: modify, close_write"
  log_info "Debounce: ${DEBOUNCE_TIME}s"

  cd "${SCRIPT_DIR}" || {
    log_error "Falha ao mudar para diretório ${SCRIPT_DIR}"
    _log_func_exit_fail "start_monitoring" "1"
    return 1
  }

  log_success "Monitoramento ativo! Aguardando mudanças..."
  echo ""
  log_info "💡 Para parar: ./watch-agents.sh --stop"
  echo ""

  # Loop de monitoramento
  while inotifywait -e modify -e close_write "${ARQUIVO_MONITORADO}" 2>/dev/null; do
    run_generator
    echo ""
    log_info "Continuando monitoramento..."
  done

  _log_func_exit_ok "start_monitoring"
  return 0
}

# Mostra uso
show_usage() {
  cat << EOF
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📖 Uso: watch-agents.sh [opção]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Opções:
  (nenhuma)         Inicia watcher em foreground
  --background, -b  Inicia watcher em background
  --stop, -s        Para watcher em background
  --status          Mostra status do watcher
  --help, -h        Mostra esta ajuda

Exemplos:
  ./watch-agents.sh              # Roda em foreground
  ./watch-agents.sh -b           # Roda em background
  ./watch-agents.sh --stop       # Para processo
  ./watch-agents.sh --status     # Verifica status

Variáveis de Ambiente:
  WATCH_AGENTS_DEBOUNCE  Tempo de espera após mudança (padrão: 2s)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
}

################################################################################
# Função Main
################################################################################

main() {
  # Processar argumentos
  local run_background=0

  case "${1:-}" in
    --stop|-s)
      _log_func_enter "main"
      stop_watcher
      _log_func_exit_ok "main"
      exit 0
      ;;
    --status)
      _log_func_enter "main"
      show_status
      _log_func_exit_ok "main"
      exit 0
      ;;
    --help|-h)
      show_usage
      exit 0
      ;;
    --background|-b)
      run_background=1
      ;;
    "")
      run_background=0
      ;;
    *)
      _log_func_enter "main"
      log_error "Opção desconhecida: $1"
      show_usage
      _log_func_exit_fail "main" "1"
      exit 1
      ;;
  esac

  _log_func_enter "main"

  # Validar dependências
  if ! check_dependencies; then
    log_error "Dependências não satisfeitas"
    _log_func_exit_fail "main" "1"
    exit 1
  fi

  # Verificar se já está rodando
  if check_running; then
    log_warning "Watcher já está rodando. Use --stop para parar primeiro."
    _log_func_exit_fail "main" "1"
    exit 1
  fi

  # Criar diretório de logs se não existir
  mkdir -p "$(dirname "${LOG_FILE}")"

  # Rodar em background ou foreground
  if [[ ${run_background} -eq 1 ]]; then
    log_info "Iniciando watcher em background..."

    # Redireciona saída para log e roda em background
    nohup bash "${BASH_SOURCE[0]}" >> "${LOG_FILE}" 2>&1 &
    local pid=$!

    echo "${pid}" > "${PID_FILE}"
    log_success "Watcher iniciado em background (PID: ${pid})"
    log_info "Log: ${LOG_FILE}"
    log_info "Para parar: ./watch-agents.sh --stop"

    _log_func_exit_ok "main"
    exit 0
  else
    # Roda em foreground
    start_monitoring
    _log_func_exit_ok "main"
    exit 0
  fi
}

# Executar main apenas se script for chamado diretamente
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi
