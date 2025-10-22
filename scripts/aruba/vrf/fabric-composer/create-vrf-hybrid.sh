#!/bin/bash
################################################################################
# Script: create-vrf-hybrid.sh
# Description: Hybrid VRF creation supporting both Fabric Composer and AOS-CX REST APIs
################################################################################
#
# DETAILED DESCRIPTION:
#   Creates Virtual Routing and Forwarding (VRF) instances using either:
#   1. HPE Aruba Networking Fabric Composer API (centralized SDN)
#   2. AOS-CX REST API (direct switch configuration)
#
#   Supports both interactive and CI/CD modes with automatic token management
#   and comprehensive error handling.
#
# ENVIRONMENT VARIABLES:
#   FABRIC COMPOSER MODE:
#     FABRIC_COMPOSER_IP: IP address or hostname of Fabric Composer
#     FABRIC_COMPOSER_USERNAME: Username for authentication
#     FABRIC_COMPOSER_PASSWORD: Password for authentication
#     FABRIC_COMPOSER_PORT: API port (default: 443)
#     FABRIC_COMPOSER_PROTOCOL: Protocol (default: https)
#
#   AOS-CX MODE:
#     AOSCX_SWITCH_IP: IP address or hostname of AOS-CX switch
#     AOSCX_USERNAME: Username for authentication
#     AOSCX_PASSWORD: Password for authentication
#     AOSCX_PORT: API port (default: 443)
#     AOSCX_PROTOCOL: Protocol (default: https)
#     AOSCX_API_VERSION: API version (default: v10.15)
#
# USAGE:
#   # Fabric Composer mode
#   ./create-vrf-hybrid.sh \
#     --mode fabric-composer \
#     --name MY-VRF \
#     --fabric default \
#     --rd 65000:100
#
#   # AOS-CX mode
#   ./create-vrf-hybrid.sh \
#     --mode aos-cx \
#     --switch cx10000.local \
#     --name MY-VRF \
#     --bgp-bestpath
#
# EXAMPLES:
#   # Fabric Composer with full config
#   ./create-vrf-hybrid.sh \
#     --mode fabric-composer \
#     --name PROD-VRF \
#     --fabric dc1-fabric \
#     --switches "CX10000,CX10001" \
#     --rd 65000:100 \
#     --rt-import "65000:100" \
#     --rt-export "65000:100" \
#     --l3-vni 10001
#
#   # AOS-CX with BGP and limits
#   ./create-vrf-hybrid.sh \
#     --mode aos-cx \
#     --switch cx10000.local \
#     --name PROD-VRF \
#     --rt-mode import \
#     --rt-af evpn \
#     --bgp-bestpath \
#     --max-sessions 10000
#
################################################################################

# Load common library
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../../lib" && pwd)/commons.sh"

################################################################################
# Global Variables
################################################################################

# Operation Mode
OPERATION_MODE="" # "fabric-composer" or "aos-cx"

# Common Configuration
ENV_FILE=""
VRF_NAME=""
VRF_DESCRIPTION=""
# INTERACTIVE_MODE=false # Variable reserved for future use
DRY_RUN=false

# Fabric Composer Specific
API_VERSION="v1"
TOKEN_FILE="${SCRIPT_DIR}/.afc_token"
TOKEN_EXPIRY_FILE="${SCRIPT_DIR}/.afc_token_expiry"
DEFAULT_TOKEN_DURATION=1800
TOKEN_REFRESH_MARGIN="${TOKEN_REFRESH_MARGIN:-300}"

FABRIC_NAME=""
SWITCHES=""
ROUTE_DISTINGUISHER=""
ROUTE_TARGET_IMPORT=""
ROUTE_TARGET_EXPORT=""
ADDRESS_FAMILY=""
L3_VNI=""
ENABLE_CONNECTION_TRACKING=false
ALLOW_SESSION_REUSE=false
ENABLE_IP_FRAGMENT_FORWARDING=false
VRF_UUID=""

# AOS-CX Specific
AOSCX_SWITCH=""
AOSCX_RT_MODE=""
AOSCX_RT_AF=""
AOSCX_RT_COMMUNITY=""
AOSCX_BGP_BESTPATH=false
AOSCX_BGP_FAST_FALLOVER=false
AOSCX_BGP_TRAP_ENABLE=false
AOSCX_BGP_LOG_NEIGHBOR_CHANGES=false
AOSCX_BGP_DETERMINISTIC_MED=false
AOSCX_BGP_COMPARE_MED=false
AOSCX_MAX_SESSIONS=""
AOSCX_MAX_CPS=""

################################################################################
# Common Functions
################################################################################

#######################################
# Display usage information
# Outputs:
#   Writes usage information to stdout
#######################################
show_usage() {
  _log_func_enter "show_usage"

  cat <<'EOF'
Usage: create-vrf-hybrid.sh --mode MODE [OPTIONS]

Creates a VRF using either Fabric Composer API or AOS-CX REST API.

REQUIRED:
  --mode MODE               Operation mode: fabric-composer | aos-cx

COMMON OPTIONS:
  -h, --help                Show this help message
  -i, --interactive         Run in interactive mode
  -e, --env-file FILE       Load environment variables from FILE
  -n, --name NAME           VRF name (required)
  -d, --description DESC    VRF description
  --dry-run                 Validate without creating

FABRIC COMPOSER MODE OPTIONS:
  -f, --fabric FABRIC       Fabric name (required for AFC)
  --switches SWITCHES       Comma-separated switch list
  -r, --rd RD               Route Distinguisher
  -I, --rt-import RT        Route Target Import
  -E, --rt-export RT        Route Target Export
  -a, --af FAMILY           Address Family (ipv4, ipv6)
  --l3-vni VNI              Layer 3 VNI
  --enable-connection-tracking
  --allow-session-reuse
  --enable-ip-fragment-forwarding

AOS-CX MODE OPTIONS:
  -s, --switch HOSTNAME     Switch hostname/IP (required for AOS-CX)
  --rt-mode MODE            Route target mode (import|export|both)
  --rt-af FAMILY            Route target address family (evpn|ipv4-unicast|ipv6-unicast)
  --rt-community COMMUNITY  Route target extended community
  --bgp-bestpath            Enable BGP bestpath
  --bgp-fast-fallover       Enable BGP fast external fallover
  --bgp-trap-enable         Enable BGP SNMP traps
  --bgp-log-neighbor-changes  Log BGP neighbor changes
  --bgp-deterministic-med   Enable deterministic MED
  --bgp-compare-med         Always compare MED
  --max-sessions NUM        Maximum sessions
  --max-cps NUM             Maximum connections per second

EXAMPLES:
  # Fabric Composer
  ./create-vrf-hybrid.sh --mode fabric-composer \
    --name PROD-VRF --fabric default --rd 65000:100

  # AOS-CX
  ./create-vrf-hybrid.sh --mode aos-cx \
    --switch cx10000.local --name PROD-VRF --bgp-bestpath

EOF

  _log_func_exit_ok "show_usage"
}

#######################################
# Check required dependencies
# Returns:
#   0 if all dependencies are met, 1 otherwise
#######################################
check_dependencies() {
  _log_func_enter "check_dependencies"

  local deps=("curl" "jq" "date")
  local missing=0

  for cmd in "${deps[@]}"; do
    if ! command -v "${cmd}" &>/dev/null; then
      log_error "Required dependency not found: ${cmd}"
      missing=1
    else
      log_debug "Dependency OK: ${cmd}"
    fi
  done

  if [[ ${missing} -eq 1 ]]; then
    log_error "Please install missing dependencies"
    _log_func_exit_fail "check_dependencies" "1"
    return 1
  fi

  _log_func_exit_ok "check_dependencies"
  return 0
}

#######################################
# Load environment variables from .env file
# Arguments:
#   $1 - Path to .env file
# Returns:
#   0 on success, 1 on failure
#######################################
load_env_file() {
  _log_func_enter "load_env_file"

  local env_file="$1"

  if [[ -z "${env_file}" ]]; then
    log_error "No environment file specified"
    _log_func_exit_fail "load_env_file" "1"
    return 1
  fi

  if [[ ! -f "${env_file}" ]]; then
    log_error "Environment file not found: ${env_file}"
    _log_func_exit_fail "load_env_file" "1"
    return 1
  fi

  log_info "Loading environment from: ${env_file}"
  # shellcheck disable=SC1090
  source "${env_file}"

  log_success "Environment loaded successfully"
  _log_func_exit_ok "load_env_file"
  return 0
}

################################################################################
# Fabric Composer Functions
################################################################################

#######################################
# Validate Fabric Composer environment variables
# Returns:
#   0 if all required variables are set, 1 otherwise
#######################################
validate_afc_environment() {
  _log_func_enter "validate_afc_environment"

  local required_vars=("FABRIC_COMPOSER_IP" "FABRIC_COMPOSER_USERNAME" "FABRIC_COMPOSER_PASSWORD")
  local missing=0

  for var in "${required_vars[@]}"; do
    if [[ -z "${!var}" ]]; then
      log_error "Required environment variable not set: ${var}"
      missing=1
    fi
  done

  # Set defaults
  FABRIC_COMPOSER_PORT="${FABRIC_COMPOSER_PORT:-443}"
  FABRIC_COMPOSER_PROTOCOL="${FABRIC_COMPOSER_PROTOCOL:-https}"

  if [[ ${missing} -eq 1 ]]; then
    _log_func_exit_fail "validate_afc_environment" "1"
    return 1
  fi

  _log_func_exit_ok "validate_afc_environment"
  return 0
}

#######################################
# Check if AFC token needs refresh
# Returns:
#   0 if needs refresh, 1 if still valid
#######################################
afc_token_needs_refresh() {
  _log_func_enter "afc_token_needs_refresh"

  if [[ ! -f "${TOKEN_FILE}" ]] || [[ ! -f "${TOKEN_EXPIRY_FILE}" ]]; then
    _log_func_exit_ok "afc_token_needs_refresh"
    return 0
  fi

  local token_expiry current_time time_until_expiry
  token_expiry=$(cat "${TOKEN_EXPIRY_FILE}")
  current_time=$(date +%s)
  time_until_expiry=$((token_expiry - current_time))

  if [[ ${time_until_expiry} -le ${TOKEN_REFRESH_MARGIN} ]]; then
    _log_func_exit_ok "afc_token_needs_refresh"
    return 0
  fi

  _log_func_exit_ok "afc_token_needs_refresh"
  return 1
}

#######################################
# Obtain AFC authentication token
# Returns:
#   0 on success, 1 on failure
#######################################
get_afc_token() {
  _log_func_enter "get_afc_token"

  if ! afc_token_needs_refresh; then
    log_info "Using existing valid AFC token"
    _log_func_exit_ok "get_afc_token"
    return 0
  fi

  log_info "Obtaining new AFC authentication token..."

  local api_url="${FABRIC_COMPOSER_PROTOCOL}://${FABRIC_COMPOSER_IP}:${FABRIC_COMPOSER_PORT}/api/${API_VERSION}/auth/token"

  log_debug "URL: ${api_url}"
  log_debug "Pattern: test-afc-auth.sh (curl -sk -w http_code -X POST -H X-Auth-Username -H X-Auth-Password -H Content-Type -d token-lifetime)"
  log_debug "Proxy env vars: HTTP_PROXY=${HTTP_PROXY:-<unset>} HTTPS_PROXY=${HTTPS_PROXY:-<unset>} http_proxy=${http_proxy:-<unset>} https_proxy=${https_proxy:-<unset>}"

  local response http_code response_body token="" current_time expiry_time

  # IMPORTANTE: Usar EXATAMENTE o mesmo padrão que funcionou no test-afc-auth.sh
  # Limpar variáveis de proxy para garantir conexão direta
  response=$(unset HTTP_PROXY HTTPS_PROXY http_proxy https_proxy ALL_PROXY all_proxy &&
    curl -sk -w "\n%{http_code}" -X POST \
      -H "X-Auth-Username: ${FABRIC_COMPOSER_USERNAME}" \
      -H "X-Auth-Password: ${FABRIC_COMPOSER_PASSWORD}" \
      -H "Content-Type: application/json" \
      -d '{"token-lifetime":30}' \
      "${api_url}" 2>&1)

  http_code=$(echo "${response}" | tail -n1)
  response_body=$(echo "${response}" | sed '$d')

  log_debug "HTTP Code: ${http_code}"
  log_debug "Response Body (primeiros 500 chars): ${response_body:0:500}"

  if [[ "${http_code}" == "200" ]]; then
    token=$(echo "${response_body}" | jq -r '.result // empty')
  fi

  if [[ -z "${token}" ]] || [[ "${token}" == "null" ]]; then
    log_error "AFC authentication failed with HTTP ${http_code}"
    log_error "Response completa: ${response_body}"
    _log_func_exit_fail "get_afc_token" "1"
    return 1
  fi

  echo "${token}" >"${TOKEN_FILE}"
  chmod 600 "${TOKEN_FILE}"

  current_time=$(date +%s)
  expiry_time=$((current_time + DEFAULT_TOKEN_DURATION))
  echo "${expiry_time}" >"${TOKEN_EXPIRY_FILE}"

  log_success "AFC authentication token obtained"
  _log_func_exit_ok "get_afc_token"
  return 0
}

#######################################
# Read AFC token from file
# Outputs:
#   Writes token to stdout
# Returns:
#   0 on success, 1 on failure
#######################################
read_afc_token() {
  _log_func_enter "read_afc_token"

  if [[ ! -f "${TOKEN_FILE}" ]]; then
    log_error "AFC token file not found"
    _log_func_exit_fail "read_afc_token" "1"
    return 1
  fi

  cat "${TOKEN_FILE}"
  _log_func_exit_ok "read_afc_token"
  return 0
}

#######################################
# Validate AFC VRF configuration
# Returns:
#   0 if valid, 1 otherwise
#######################################
validate_afc_config() {
  _log_func_enter "validate_afc_config"

  local errors=0

  if [[ -z "${VRF_NAME}" ]]; then
    log_error "VRF name is required"
    errors=1
  fi

  if [[ -z "${FABRIC_NAME}" ]]; then
    log_error "Fabric name is required for AFC mode"
    errors=1
  fi

  if [[ ${errors} -eq 1 ]]; then
    _log_func_exit_fail "validate_afc_config" "1"
    return 1
  fi

  _log_func_exit_ok "validate_afc_config"
  return 0
}

#######################################
# Build AFC VRF JSON payload
# Outputs:
#   Writes JSON to stdout
# Returns:
#   0 on success, 1 on failure
#######################################
build_afc_payload() {
  _log_func_enter "build_afc_payload"

  local payload

  payload=$(jq -n \
    --arg name "${VRF_NAME}" \
    --arg fabric "${FABRIC_NAME}" \
    '{name: $name, fabric: $fabric}')

  if [[ -n "${VRF_DESCRIPTION}" ]]; then
    payload=$(echo "${payload}" | jq --arg desc "${VRF_DESCRIPTION}" '. + {description: $desc}')
  fi

  if [[ -n "${SWITCHES}" ]]; then
    IFS=',' read -ra sw_array <<<"${SWITCHES}"
    local sw_json
    sw_json=$(printf '%s\n' "${sw_array[@]}" | jq -R . | jq -s .)
    payload=$(echo "${payload}" | jq --argjson sw "${sw_json}" '. + {switches: $sw}')
  fi

  if [[ -n "${ROUTE_DISTINGUISHER}" ]]; then
    payload=$(echo "${payload}" | jq --arg rd "${ROUTE_DISTINGUISHER}" '. + {route_distinguisher: $rd}')
  fi

  if [[ -n "${ROUTE_TARGET_IMPORT}" ]]; then
    IFS=',' read -ra rt_import <<<"${ROUTE_TARGET_IMPORT}"
    local rt_json
    rt_json=$(printf '%s\n' "${rt_import[@]}" | jq -R . | jq -s .)
    payload=$(echo "${payload}" | jq --argjson rt "${rt_json}" '. + {"route-target-import": $rt}')
  fi

  if [[ -n "${ROUTE_TARGET_EXPORT}" ]]; then
    IFS=',' read -ra rt_export <<<"${ROUTE_TARGET_EXPORT}"
    local rt_json
    rt_json=$(printf '%s\n' "${rt_export[@]}" | jq -R . | jq -s .)
    payload=$(echo "${payload}" | jq --argjson rt "${rt_json}" '. + {"route-target-export": $rt}')
  fi

  if [[ -n "${ADDRESS_FAMILY}" ]]; then
    IFS=',' read -ra af_array <<<"${ADDRESS_FAMILY}"
    local af_json
    af_json=$(printf '%s\n' "${af_array[@]}" | jq -R . | jq -s .)
    payload=$(echo "${payload}" | jq --argjson af "${af_json}" '. + {"address-family": $af}')
  fi

  if [[ -n "${L3_VNI}" ]]; then
    payload=$(echo "${payload}" | jq --argjson vni "${L3_VNI}" '. + {l3_vni: $vni}')
  fi

  if [[ "${ENABLE_CONNECTION_TRACKING}" == "true" ]]; then
    payload=$(echo "${payload}" | jq '. + {enable_connection_tracking_mode: true}')
  fi

  if [[ "${ALLOW_SESSION_REUSE}" == "true" ]]; then
    payload=$(echo "${payload}" | jq '. + {allow_session_reuse: true}')
  fi

  if [[ "${ENABLE_IP_FRAGMENT_FORWARDING}" == "true" ]]; then
    payload=$(echo "${payload}" | jq '. + {enable_ip_fragment_forwarding: true}')
  fi

  echo "${payload}"
  _log_func_exit_ok "build_afc_payload"
  return 0
}

#######################################
# Create VRF via Fabric Composer
# Returns:
#   0 on success, 1 on failure
#######################################
create_vrf_afc() {
  _log_func_enter "create_vrf_afc"

  log_section "CREATING VRF (FABRIC COMPOSER)"

  if ! get_afc_token; then
    log_error "Failed to obtain AFC token"
    _log_func_exit_fail "create_vrf_afc" "1"
    return 1
  fi

  local token payload api_url response http_code response_body

  if ! token=$(read_afc_token); then
    log_error "Failed to read AFC token"
    _log_func_exit_fail "create_vrf_afc" "1"
    return 1
  fi

  if ! payload=$(build_afc_payload); then
    log_error "Failed to build AFC payload"
    _log_func_exit_fail "create_vrf_afc" "1"
    return 1
  fi

  log_info "VRF Configuration:"
  echo "${payload}" | jq '.'

  if [[ "${DRY_RUN}" == "true" ]]; then
    log_info "DRY RUN mode - VRF would be created"
    _log_func_exit_ok "create_vrf_afc"
    return 0
  fi

  api_url="${FABRIC_COMPOSER_PROTOCOL}://${FABRIC_COMPOSER_IP}:${FABRIC_COMPOSER_PORT}/api/${API_VERSION}/sites/default/vrfs"

  log_info "Creating VRF '${VRF_NAME}'..."

  response=$(curl -s -w "\n%{http_code}" -X POST \
    -H "Content-Type: application/json" \
    -H "Authorization: ${token}" \
    -H "X-Auth-Refresh-Token: true" \
    -d "${payload}" \
    --insecure \
    "${api_url}" 2>&1)

  http_code=$(echo "${response}" | tail -n1)
  response_body=$(echo "${response}" | sed '$d')

  if [[ "${http_code}" =~ ^20[0-9]$ ]]; then
    log_success "VRF '${VRF_NAME}' created successfully"
    echo "${response_body}" | jq '.' 2>/dev/null || echo "${response_body}"

    VRF_UUID=$(echo "${response_body}" | jq -r '.uuid // .id // empty' 2>/dev/null)
    if [[ -n "${VRF_UUID}" ]] && [[ "${VRF_UUID}" != "null" ]]; then
      log_success "VRF UUID: ${VRF_UUID}"
    fi

    _log_func_exit_ok "create_vrf_afc"
    return 0
  else
    log_error "Failed to create VRF (HTTP ${http_code})"
    log_error "Response: ${response_body}"
    _log_func_exit_fail "create_vrf_afc" "1"
    return 1
  fi
}

#######################################
# Apply VRF configuration (AFC)
# Returns:
#   0 on success, 1 on failure
#######################################
apply_vrf_afc() {
  _log_func_enter "apply_vrf_afc"

  log_section "APPLYING VRF CONFIGURATION (AFC)"

  if [[ -z "${VRF_UUID}" ]] || [[ "${VRF_UUID}" == "null" ]]; then
    log_info "VRF UUID not available - skipping apply step"
    _log_func_exit_ok "apply_vrf_afc"
    return 0
  fi

  if ! get_afc_token; then
    log_error "Failed to obtain AFC token for apply"
    _log_func_exit_fail "apply_vrf_afc" "1"
    return 1
  fi

  local token api_url response http_code response_body

  if ! token=$(read_afc_token); then
    log_error "Failed to read AFC token"
    _log_func_exit_fail "apply_vrf_afc" "1"
    return 1
  fi

  api_url="${FABRIC_COMPOSER_PROTOCOL}://${FABRIC_COMPOSER_IP}:${FABRIC_COMPOSER_PORT}/api/${API_VERSION}/sites/default/vrfs/${VRF_UUID}/apply"

  log_info "Applying VRF configuration..."

  response=$(curl -s -w "\n%{http_code}" -X POST \
    -H "Content-Type: application/json" \
    -H "Authorization: ${token}" \
    -H "X-Auth-Refresh-Token: true" \
    --insecure \
    "${api_url}" 2>&1)

  http_code=$(echo "${response}" | tail -n1)
  response_body=$(echo "${response}" | sed '$d')

  if [[ "${http_code}" =~ ^20[0-9]$ ]]; then
    log_success "VRF configuration applied successfully"
    _log_func_exit_ok "apply_vrf_afc"
    return 0
  else
    log_error "Failed to apply VRF (HTTP ${http_code})"
    _log_func_exit_fail "apply_vrf_afc" "1"
    return 1
  fi
}

################################################################################
# AOS-CX Functions
################################################################################

#######################################
# Validate AOS-CX environment variables
# Returns:
#   0 if all required variables are set, 1 otherwise
#######################################
validate_aoscx_environment() {
  _log_func_enter "validate_aoscx_environment"

  # For AOS-CX, we can use --switch parameter or env vars
  if [[ -z "${AOSCX_SWITCH}" ]]; then
    if [[ -z "${AOSCX_SWITCH_IP}" ]]; then
      log_error "Switch hostname/IP required (use --switch or AOSCX_SWITCH_IP)"
      _log_func_exit_fail "validate_aoscx_environment" "1"
      return 1
    fi
    AOSCX_SWITCH="${AOSCX_SWITCH_IP}"
  fi

  # Set defaults
  AOSCX_PORT="${AOSCX_PORT:-443}"
  AOSCX_PROTOCOL="${AOSCX_PROTOCOL:-https}"
  AOSCX_API_VERSION="${AOSCX_API_VERSION:-v10.15}"

  _log_func_exit_ok "validate_aoscx_environment"
  return 0
}

#######################################
# Validate AOS-CX VRF configuration
# Returns:
#   0 if valid, 1 otherwise
#######################################
validate_aoscx_config() {
  _log_func_enter "validate_aoscx_config"

  local errors=0

  if [[ -z "${VRF_NAME}" ]]; then
    log_error "VRF name is required"
    errors=1
  fi

  if [[ -z "${AOSCX_SWITCH}" ]]; then
    log_error "Switch hostname/IP is required for AOS-CX mode"
    errors=1
  fi

  if [[ ${errors} -eq 1 ]]; then
    _log_func_exit_fail "validate_aoscx_config" "1"
    return 1
  fi

  _log_func_exit_ok "validate_aoscx_config"
  return 0
}

#######################################
# Build AOS-CX VRF JSON payload
# Outputs:
#   Writes JSON to stdout
# Returns:
#   0 on success, 1 on failure
#######################################
build_aoscx_payload() {
  _log_func_enter "build_aoscx_payload"

  local payload

  payload=$(jq -n --arg name "${VRF_NAME}" '{name: $name}')

  # Route Target
  if [[ -n "${AOSCX_RT_MODE}" ]] || [[ -n "${AOSCX_RT_AF}" ]]; then
    local rt_obj="{}"

    if [[ -n "${AOSCX_RT_AF}" ]]; then
      rt_obj=$(echo "${rt_obj}" | jq --arg af "${AOSCX_RT_AF}" '. + {address_family: $af}')
    fi

    if [[ -n "${AOSCX_RT_MODE}" ]]; then
      rt_obj=$(echo "${rt_obj}" | jq --arg mode "${AOSCX_RT_MODE}" '. + {route_mode: $mode}')
    fi

    if [[ -n "${AOSCX_RT_COMMUNITY}" ]]; then
      rt_obj=$(echo "${rt_obj}" | jq --arg comm "${AOSCX_RT_COMMUNITY}" '. + {ext_community: $comm}')
    fi

    payload=$(echo "${payload}" | jq --argjson rt "${rt_obj}" '. + {route_target: {primary_route_target: $rt}}')
  fi

  # BGP Configuration
  local bgp_config="{}"
  local has_bgp=false

  if [[ "${AOSCX_BGP_BESTPATH}" == "true" ]]; then
    bgp_config=$(echo "${bgp_config}" | jq '. + {bestpath: true}')
    has_bgp=true
  fi

  if [[ "${AOSCX_BGP_FAST_FALLOVER}" == "true" ]]; then
    bgp_config=$(echo "${bgp_config}" | jq '. + {fast_external_fallover: true}')
    has_bgp=true
  fi

  if [[ "${AOSCX_BGP_TRAP_ENABLE}" == "true" ]]; then
    bgp_config=$(echo "${bgp_config}" | jq '. + {trap_enable: true}')
    has_bgp=true
  fi

  if [[ "${AOSCX_BGP_LOG_NEIGHBOR_CHANGES}" == "true" ]]; then
    bgp_config=$(echo "${bgp_config}" | jq '. + {log_neighbor_changes: true}')
    has_bgp=true
  fi

  if [[ "${AOSCX_BGP_DETERMINISTIC_MED}" == "true" ]]; then
    bgp_config=$(echo "${bgp_config}" | jq '. + {deterministic_med: true}')
    has_bgp=true
  fi

  if [[ "${AOSCX_BGP_COMPARE_MED}" == "true" ]]; then
    bgp_config=$(echo "${bgp_config}" | jq '. + {always_compare_med: true}')
    has_bgp=true
  fi

  if [[ "${has_bgp}" == "true" ]]; then
    payload=$(echo "${payload}" | jq --argjson bgp "${bgp_config}" '. + {bgp: $bgp}')
  fi

  # Session Limits
  if [[ -n "${AOSCX_MAX_SESSIONS}" ]]; then
    payload=$(echo "${payload}" | jq --argjson max "${AOSCX_MAX_SESSIONS}" '. + {max_sessions: $max, max_sessions_mode: "limited"}')
  fi

  if [[ -n "${AOSCX_MAX_CPS}" ]]; then
    payload=$(echo "${payload}" | jq --argjson max "${AOSCX_MAX_CPS}" '. + {max_cps: $max, max_cps_mode: "limited"}')
  fi

  echo "${payload}"
  _log_func_exit_ok "build_aoscx_payload"
  return 0
}

#######################################
# Create VRF via AOS-CX REST API
# Returns:
#   0 on success, 1 on failure
#######################################
create_vrf_aoscx() {
  _log_func_enter "create_vrf_aoscx"

  log_section "CREATING VRF (AOS-CX REST API)"

  local payload api_url response http_code response_body auth_header

  if ! payload=$(build_aoscx_payload); then
    log_error "Failed to build AOS-CX payload"
    _log_func_exit_fail "create_vrf_aoscx" "1"
    return 1
  fi

  log_info "VRF Configuration:"
  echo "${payload}" | jq '.'

  if [[ "${DRY_RUN}" == "true" ]]; then
    log_info "DRY RUN mode - VRF would be created"
    _log_func_exit_ok "create_vrf_aoscx"
    return 0
  fi

  api_url="${AOSCX_PROTOCOL}://${AOSCX_SWITCH}:${AOSCX_PORT}/rest/${AOSCX_API_VERSION}/system/vrfs"

  log_info "Creating VRF '${VRF_NAME}' on switch '${AOSCX_SWITCH}'..."

  # Use basic auth if credentials are available
  if [[ -n "${AOSCX_USERNAME}" ]] && [[ -n "${AOSCX_PASSWORD}" ]]; then
    auth_header="-u ${AOSCX_USERNAME}:${AOSCX_PASSWORD}"
  else
    auth_header=""
  fi

  response=$(curl -s -w "\n%{http_code}" -X POST \
    -H "Content-Type: application/json" \
    "${auth_header}" \
    -d "${payload}" \
    --insecure \
    "${api_url}" 2>&1)

  http_code=$(echo "${response}" | tail -n1)
  response_body=$(echo "${response}" | sed '$d')

  if [[ "${http_code}" =~ ^20[0-9]$ ]]; then
    log_success "VRF '${VRF_NAME}' created successfully on ${AOSCX_SWITCH}"
    echo "${response_body}" | jq '.' 2>/dev/null || echo "${response_body}"
    _log_func_exit_ok "create_vrf_aoscx"
    return 0
  else
    log_error "Failed to create VRF (HTTP ${http_code})"
    log_error "Response: ${response_body}"
    _log_func_exit_fail "create_vrf_aoscx" "1"
    return 1
  fi
}

################################################################################
# Argument Parsing
################################################################################

#######################################
# Parse command line arguments
# Arguments:
#   $@ - All command line arguments
# Returns:
#   0 on success, 1 on failure
#######################################
parse_arguments() {
  _log_func_enter "parse_arguments"

  while [[ $# -gt 0 ]]; do
    case $1 in
    -h | --help)
      show_usage
      _log_func_exit_ok "parse_arguments"
      exit 0
      ;;
    --mode)
      OPERATION_MODE="$2"
      shift 2
      ;;
    -i | --interactive)
      # INTERACTIVE_MODE=true # Unused variable removed
      shift
      ;;
    -e | --env-file)
      ENV_FILE="$2"
      shift 2
      ;;
    -n | --name)
      VRF_NAME="$2"
      shift 2
      ;;
    -d | --description)
      VRF_DESCRIPTION="$2"
      shift 2
      ;;
    --dry-run)
      DRY_RUN=true
      shift
      ;;
    # Fabric Composer options
    -f | --fabric)
      FABRIC_NAME="$2"
      shift 2
      ;;
    --switches)
      SWITCHES="$2"
      shift 2
      ;;
    -r | --rd)
      ROUTE_DISTINGUISHER="$2"
      shift 2
      ;;
    -I | --rt-import)
      ROUTE_TARGET_IMPORT="$2"
      shift 2
      ;;
    -E | --rt-export)
      ROUTE_TARGET_EXPORT="$2"
      shift 2
      ;;
    -a | --af)
      ADDRESS_FAMILY="$2"
      shift 2
      ;;
    --l3-vni)
      L3_VNI="$2"
      shift 2
      ;;
    --enable-connection-tracking)
      ENABLE_CONNECTION_TRACKING=true
      shift
      ;;
    --allow-session-reuse)
      ALLOW_SESSION_REUSE=true
      shift
      ;;
    --enable-ip-fragment-forwarding)
      ENABLE_IP_FRAGMENT_FORWARDING=true
      shift
      ;;
    # AOS-CX options
    -s | --switch)
      AOSCX_SWITCH="$2"
      shift 2
      ;;
    --rt-mode)
      AOSCX_RT_MODE="$2"
      shift 2
      ;;
    --rt-af)
      AOSCX_RT_AF="$2"
      shift 2
      ;;
    --rt-community)
      AOSCX_RT_COMMUNITY="$2"
      shift 2
      ;;
    --bgp-bestpath)
      AOSCX_BGP_BESTPATH=true
      shift
      ;;
    --bgp-fast-fallover)
      AOSCX_BGP_FAST_FALLOVER=true
      shift
      ;;
    --bgp-trap-enable)
      AOSCX_BGP_TRAP_ENABLE=true
      shift
      ;;
    --bgp-log-neighbor-changes)
      AOSCX_BGP_LOG_NEIGHBOR_CHANGES=true
      shift
      ;;
    --bgp-deterministic-med)
      AOSCX_BGP_DETERMINISTIC_MED=true
      shift
      ;;
    --bgp-compare-med)
      AOSCX_BGP_COMPARE_MED=true
      shift
      ;;
    --max-sessions)
      AOSCX_MAX_SESSIONS="$2"
      shift 2
      ;;
    --max-cps)
      AOSCX_MAX_CPS="$2"
      shift 2
      ;;
    *)
      log_error "Unknown parameter: $1"
      show_usage
      _log_func_exit_fail "parse_arguments" "1"
      exit 1
      ;;
    esac
  done

  _log_func_exit_ok "parse_arguments"
  return 0
}

################################################################################
# Main Function
################################################################################

main() {
  _log_func_enter "main"

  log_section "HYBRID VRF CREATION - FABRIC COMPOSER / AOS-CX"

  # Check dependencies
  if ! check_dependencies; then
    log_error "Dependency check failed"
    _log_func_exit_fail "main" "1"
    exit 1
  fi

  # Parse arguments
  if ! parse_arguments "$@"; then
    log_error "Failed to parse arguments"
    _log_func_exit_fail "main" "1"
    exit 1
  fi

  # Load environment file if specified
  if [[ -n "${ENV_FILE}" ]]; then
    if ! load_env_file "${ENV_FILE}"; then
      log_error "Failed to load environment file"
      _log_func_exit_fail "main" "1"
      exit 1
    fi
  fi

  # Validate operation mode
  if [[ -z "${OPERATION_MODE}" ]]; then
    log_error "Operation mode is required (--mode fabric-composer | aos-cx)"
    show_usage
    _log_func_exit_fail "main" "1"
    exit 1
  fi

  if [[ "${OPERATION_MODE}" != "fabric-composer" ]] && [[ "${OPERATION_MODE}" != "aos-cx" ]]; then
    log_error "Invalid mode: ${OPERATION_MODE}"
    log_error "Valid modes: fabric-composer, aos-cx"
    _log_func_exit_fail "main" "1"
    exit 1
  fi

  log_info "Operation mode: ${OPERATION_MODE}"

  # Execute based on mode
  if [[ "${OPERATION_MODE}" == "fabric-composer" ]]; then
    log_section "FABRIC COMPOSER MODE"

    if ! validate_afc_environment; then
      log_error "AFC environment validation failed"
      _log_func_exit_fail "main" "1"
      exit 1
    fi

    if ! validate_afc_config; then
      log_error "AFC configuration validation failed"
      _log_func_exit_fail "main" "1"
      exit 1
    fi

    if ! create_vrf_afc; then
      log_error "VRF creation failed (AFC)"
      _log_func_exit_fail "main" "1"
      exit 1
    fi

    if [[ "${DRY_RUN}" != "true" ]]; then
      if ! apply_vrf_afc; then
        log_warning "VRF created but apply step failed"
        _log_func_exit_fail "main" "1"
        exit 1
      fi
    fi

  elif [[ "${OPERATION_MODE}" == "aos-cx" ]]; then
    log_section "AOS-CX REST API MODE"

    if ! validate_aoscx_environment; then
      log_error "AOS-CX environment validation failed"
      _log_func_exit_fail "main" "1"
      exit 1
    fi

    if ! validate_aoscx_config; then
      log_error "AOS-CX configuration validation failed"
      _log_func_exit_fail "main" "1"
      exit 1
    fi

    if ! create_vrf_aoscx; then
      log_error "VRF creation failed (AOS-CX)"
      _log_func_exit_fail "main" "1"
      exit 1
    fi
  fi

  log_section "OPERATION COMPLETED"
  log_success "VRF creation completed successfully"

  _log_func_exit_ok "main"
  exit 0
}

# Execute main only if script is called directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi
