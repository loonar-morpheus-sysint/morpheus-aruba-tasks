#!/bin/bash
################################################################################
# Script: create-vrf-afc.sh
# Description: Advanced automation for VRF creation on HPE Aruba Networking Fabric Composer
################################################################################
#
# DETAILED DESCRIPTION:
#   Creates and applies Virtual Routing and Forwarding (VRF) instances on HPE
#   Aruba Networking Fabric Composer using the REST API. The script performs
#   two main operations:
#     1. VRF Creation: Defines the VRF with routing parameters
#     2. VRF Application: Applies the configuration to the fabric
#
#   Features:
#     - Interactive and CI/CD modes
#     - Automatic token management with refresh (30-min lifetime)
#     - Dry-run mode for validation before deployment
#     - Comprehensive error handling and validation
#     - Support for IPv4, IPv6, or dual-stack VRFs
#     - Token persistence across invocations
#
# ENVIRONMENT VARIABLES (Required):
#   FABRIC_COMPOSER_IP        IP address or hostname of Fabric Composer
#   FABRIC_COMPOSER_USERNAME  Username for API authentication
#   FABRIC_COMPOSER_PASSWORD  Password for API authentication
#
# ENVIRONMENT VARIABLES (Optional):
#   FABRIC_COMPOSER_PORT      API port (default: 443)
#   FABRIC_COMPOSER_PROTOCOL  Protocol: http or https (default: https)
#   TOKEN_REFRESH_MARGIN      Seconds before expiry to refresh token (default: 300)
#
# TOKEN MANAGEMENT:
#   The script automatically manages authentication tokens:
#     - Token cached in: .afc_token
#     - Expiry tracked in: .afc_token_expiry
#     - Auto-refresh: 5 minutes before expiration
#     - Token lifetime: 30 minutes (configurable on AFC)
#
# RETURN CODES:
#   0 - Success (VRF created and applied)
#   1 - Failure (dependency missing, validation failed, API error, etc.)
#
# USAGE:
#   # Interactive mode (prompts for all parameters)
#   ./create-vrf-afc.sh --interactive
#   # Pattern for tests: -i|--interactive
#
#   # CI/CD mode with minimal parameters
#   ./create-vrf-afc.sh --name MY-VRF --fabric fabric1 --rd 65000:100
#
#   # CI/CD mode with full configuration
#   ./create-vrf-afc.sh --name MY-VRF --fabric fabric1 --rd 65000:100 \
#     --rt-import 65000:100 --rt-export 65000:100 --af ipv4 \
#     --description "My Production VRF"
#
#   # Load environment from .env file
#   ./create-vrf-afc.sh --env-file /path/to/.env --name MY-VRF \
#     --fabric fabric1 --rd 65000:100
#
#   # Dry-run mode (validate without creating)
#   ./create-vrf-afc.sh --name TEST-VRF --fabric dc1 --rd 65000:100 --dry-run
#
# EXAMPLES (not using real secrets):
#   # Example 1: Simple VRF with IPv4 only
#   export FABRIC_COMPOSER_IP="<YOUR VALUE>"
#   export FABRIC_COMPOSER_USERNAME="<YOUR VALUE>"
#   export FABRIC_COMPOSER_PASSWORD="<YOUR VALUE>" # pragma: allowlist secret

#   ./create-vrf-afc.sh --name PROD-VRF --fabric dc1-fabric --rd 65000:100
#
#   # Example 2: VRF with EVPN and VNI
#   ./create-vrf-afc.sh \
#     --name CUSTOMER-A-VRF \
#     --fabric dc1-fabric \
#     --rd 65000:100 \
#     --rt-import "65000:100" \
#     --rt-export "65000:100" \
#     --af evpn \
#     --vni 5000 \
#     --description "Customer A Production VRF"
#
#   # Example 3: Using environment file for credentials
#   cat > /tmp/afc.env << EOF
#   FABRIC_COMPOSER_IP=10.1.1.100
#   FABRIC_COMPOSER_USERNAME=admin
#   FABRIC_COMPOSER_PASSWORD=secret123
#   FABRIC_COMPOSER_PORT=443
#   FABRIC_COMPOSER_PROTOCOL=https
#   EOF
#   ./create-vrf-afc.sh --env-file /tmp/afc.env \
#     --name DEV-VRF --fabric dc1 --rd 65000:200
#
#   # Example 4: Validate configuration before deployment
#   ./create-vrf-afc.sh \
#     --name TEST-VRF \
#     --fabric dc1 \
#     --rd 65000:300 \
#     --rt-import 65000:300 \
#     --rt-export 65000:300 \
#     --dry-run
#
#   # Example 5: Interactive mode (script prompts for all values)
#   ./create-vrf-afc.sh --interactive
#
# TROUBLESHOOTING:
#   # Force token refresh (delete cached token)
#   rm -f .afc_token .afc_token_expiry
#
#   # Check token expiration
#   [ -f .afc_token_expiry ] && date -d "@$(cat .afc_token_expiry)"
#
#   # Test API connectivity
#   curl -k https://${FABRIC_COMPOSER_IP}:443/api/v1/health
#
#   # Enable debug logging
#   export LOG_LEVEL=DEBUG
#   ./create-vrf-afc.sh --name TEST-VRF --fabric dc1 --rd 65000:100
#
# API REFERENCES:
#   - AFC API Getting Started:
#     https://developer.arubanetworks.com/afc/docs/getting-started-with-the-afc-api
#   - VRF Creation API (Official):
#     https://developer.arubanetworks.com/afc/reference/createvrf-1
#   - VRF Documentation:
#     https://arubanetworking.hpe.com/techdocs/AFC/700/Content/afc70olh/add-vrf.htm
#   - Authentication API:
#     https://developer.arubanetworks.com/afc/reference/getapikey-1
#   - Ansible Collection (reference implementation):
#     https://github.com/aruba/hpeanfc-ansible-collection
#
# NOTES:
#   - VRF names must contain only alphanumeric characters, dashes, and underscores
#   - Fabric name is automatically resolved to fabric_uuid via API lookup
#   - Route Distinguisher format: ASN:NN (e.g., 65000:100)
#   - Route Targets are converted to AFC API route_target object structure
#   - Switch UUIDs are optional; if not provided, script attempts to auto-discover
#   - VNI (VXLAN Network Identifier) must be between 1 and 16777214 if specified
#   - Address Family defaults to 'ipv4', can be 'ipv6' or 'evpn'
#   - VRF creation via POST /api/vrfs should auto-apply configuration
#   - Script follows official AFC API specification from developer.arubanetworks.com
#
################################################################################

# Load common library
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091

source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../../lib" && pwd)/commons.sh"

# Pre-scan arguments for --no-install
NO_INSTALL=false
for _a in "${@}"; do
  if [[ "${_a}" == "--no-install" ]]; then
    NO_INSTALL=true
    break
  fi
done

# Ensure jq is installed (utility may install it) unless disabled by --no-install
if [[ "${NO_INSTALL}" != "true" ]] && [[ -f "$(dirname "${BASH_SOURCE[0]}")/../../../../utilities/install-jq.sh" ]]; then
  # shellcheck disable=SC1091
  source "$(dirname "${BASH_SOURCE[0]}")/../../../../utilities/install-jq.sh"
  if ! ensure_jq_installed; then
    log_error "jq installation or verification failed"
    exit 1
  fi
elif [[ "${NO_INSTALL}" == "true" ]]; then
  log_info "--no-install specified: skipping jq installation. Ensure jq is available."
fi

################################################################################
# Global Variables
################################################################################

# API Configuration
API_VERSION="v1"
TOKEN_FILE="${SCRIPT_DIR}/.afc_token"
TOKEN_EXPIRY_FILE="${SCRIPT_DIR}/.afc_token_expiry"
DEFAULT_TOKEN_DURATION=1800                         # 30 minutes in seconds
TOKEN_REFRESH_MARGIN="${TOKEN_REFRESH_MARGIN:-300}" # 5 minutes before expiry

# Script Configuration
ENV_FILE=""
VRF_NAME=""
VRF_DESCRIPTION=""
FABRIC_NAME=""
FABRIC_UUID=""  # UUID of the fabric (required by API)
SWITCH_UUIDS="" # Comma-separated list of switch UUIDs (optional)
ROUTE_DISTINGUISHER=""
ROUTE_TARGET_IMPORT=""
ROUTE_TARGET_EXPORT=""
MAX_SESSIONS_MODE="unlimited"
MAX_CPS_MODE="unlimited"
MAX_SESSIONS=""
MAX_CPS=""
ADDRESS_FAMILY="ipv4" # Default: ipv4
VNI=""                # L2/L3 VPN VNI (optional)
INTERACTIVE_MODE=false
DRY_RUN=false
VRF_UUID="" # Stores VRF UUID after creation

################################################################################
# Functions
################################################################################

#######################################
# Display usage information
# Outputs:
#   Writes usage information to stdout
#######################################
show_usage() {
  _log_func_enter "show_usage"

  cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Creates a VRF on HPE Aruba Networking Fabric Composer.

OPTIONS:
  -h, --help                Show this help message
  -i, --interactive         Run in interactive mode (prompts for input)
  -e, --env-file FILE       Load environment variables from FILE
  -n, --name NAME           VRF name (required)
  -f, --fabric FABRIC       Fabric name (required - will be resolved to UUID)
  -r, --rd RD               Route Distinguisher (e.g., 65000:100)
  -I, --rt-import RT        Route Target Import (comma-separated)
  -E, --rt-export RT        Route Target Export (comma-separated)
  -a, --af FAMILY           Address Family: ipv4, ipv6, evpn (default: ipv4)
  -v, --vni VNI             L2/L3 VPN VNI (1-16777214)
  --max-sessions-mode MODE  max sessions mode: unlimited|limited (default: unlimited)
  --max-cps-mode MODE       max cps mode: unlimited|limited (default: unlimited)
  --max-sessions NUM        max sessions (required if mode=limited)
  --max-cps NUM             max cps (required if mode=limited)
  -s, --switches UUIDS      Comma-separated switch UUIDs (optional)
  -d, --description DESC    VRF description
  --dry-run                 Validate configuration without creating VRF
  --no-install              Do not attempt to install dependencies (jq)

ENVIRONMENT VARIABLES:
  FABRIC_COMPOSER_IP        Fabric Composer IP/hostname (required)
  FABRIC_COMPOSER_USERNAME  API username (required)
  FABRIC_COMPOSER_PASSWORD  API password (required)
  FABRIC_COMPOSER_PORT      API port (default: 443)
  FABRIC_COMPOSER_PROTOCOL  Protocol: http or https (default: https)
  TOKEN_REFRESH_MARGIN      Token refresh margin in seconds (default: 300)

EXAMPLES:
  # Interactive mode
  $(basename "$0") --interactive

  # CI/CD mode
  $(basename "$0") --name PROD-VRF --fabric dc1 --rd 65000:100

  # Full configuration
  $(basename "$0") \\
    --name PROD-VRF \\
    --fabric dc1-fabric \\
    --rd 65000:100 \\
    --rt-import "65000:100,65000:200" \\
    --rt-export "65000:100" \\
    --af "ipv4,ipv6" \\
    --description "Production VRF"

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

  local deps=("curl" "date")
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
    log_error "Please install missing dependencies before continuing"
    _log_func_exit_fail "check_dependencies" "1"
    return 1
  fi

  # JSON parser check: jq is required
  if command -v jq >/dev/null 2>&1; then
    log_debug "Dependency OK: jq"
  else
    log_warn "jq not found; it should have been installed by ensure_jq_installed() or present in the environment"
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

#######################################
# Validate required environment variables
# Returns:
#   0 if all required variables are set, 1 otherwise
#######################################
validate_environment() {
  _log_func_enter "validate_environment"

  local required_vars=("FABRIC_COMPOSER_IP" "FABRIC_COMPOSER_USERNAME" "FABRIC_COMPOSER_PASSWORD")
  local missing=0

  for var in "${required_vars[@]}"; do
    if [[ -z "${!var:-}" ]]; then
      log_error "Required environment variable not set: ${var}"
      missing=1
    else
      log_debug "Environment variable OK: ${var}"
    fi
  done

  # Set defaults
  FABRIC_COMPOSER_PORT="${FABRIC_COMPOSER_PORT:-443}"
  FABRIC_COMPOSER_PROTOCOL="${FABRIC_COMPOSER_PROTOCOL:-https}"

  if [[ ${missing} -eq 1 ]]; then
    log_error "Please set all required environment variables"
    _log_func_exit_fail "validate_environment" "1"
    return 1
  fi

  log_debug "Using Fabric Composer: ${FABRIC_COMPOSER_PROTOCOL}://${FABRIC_COMPOSER_IP}:${FABRIC_COMPOSER_PORT}"

  _log_func_exit_ok "validate_environment"
  return 0
}

#######################################
# Check if token is expired or needs refresh
# Returns:
#   0 if token needs refresh, 1 if token is still valid
#######################################
token_needs_refresh() {
  _log_func_enter "token_needs_refresh"

  if [[ ! -f "${TOKEN_FILE}" ]] || [[ ! -f "${TOKEN_EXPIRY_FILE}" ]]; then
    log_debug "Token file not found, refresh needed"
    _log_func_exit_ok "token_needs_refresh"
    return 0
  fi

  local token_expiry
  token_expiry=$(cat "${TOKEN_EXPIRY_FILE}")
  current_time=$(date +%s)
  time_until_expiry=$((token_expiry - current_time))

  log_debug "Token expires in ${time_until_expiry} seconds"

  if [[ ${time_until_expiry} -le ${TOKEN_REFRESH_MARGIN} ]]; then
    log_info "Token expires soon, refresh needed"
    _log_func_exit_ok "token_needs_refresh"
    return 0
  fi

  log_debug "Token is still valid"
  _log_func_exit_ok "token_needs_refresh"
  return 1
}

#######################################
# Obtain authentication token from Fabric Composer API
# Returns:
#   0 on success, 1 on failure
#######################################
get_auth_token() {
  _log_func_enter "get_auth_token"

  if ! token_needs_refresh; then
    log_info "Using existing valid token"
    _log_func_exit_ok "get_auth_token"
    return 0
  fi

  log_info "Obtaining new authentication token..."

  local api_url="${FABRIC_COMPOSER_PROTOCOL}://${FABRIC_COMPOSER_IP}:${FABRIC_COMPOSER_PORT}/api/${API_VERSION}/auth/token"
  local auth_payload
  auth_payload=$(jq -n \
    --arg username "${FABRIC_COMPOSER_USERNAME}" \
    --arg password "${FABRIC_COMPOSER_PASSWORD}" \
    '{username: $username, password: $password}')

  local response
  local http_code
  local response_body
  local token

  # Attempt 1: JSON body auth
  response=$(curl --max-time 15 --connect-timeout 5 -s -w "\n%{http_code}" -X POST \
    -H "Content-Type: application/json" \
    -d "${auth_payload}" \
    --insecure \
    "${api_url}" 2>&1)

  http_code=$(echo "${response}" | tail -n1)
  response_body=$(echo "${response}" | sed '$d')

  log_debug "HTTP Status Code: ${http_code}"

  if [[ "${http_code}" == "200" ]]; then
    token=$(echo "${response_body}" | jq -r '.token // .access_token // empty')
  fi

  # Attempt 2: Basic Auth header (matches error complaining about headers)
  if [[ -z "${token}" || "${token}" == "null" || "${http_code}" == "400" && "${response_body}" == *"not in request headers"* ]]; then
    log_info "Retrying auth using Basic Auth header"
    response=$(curl --max-time 15 --connect-timeout 5 -s -w "\n%{http_code}" -X POST \
      -u "${FABRIC_COMPOSER_USERNAME}:${FABRIC_COMPOSER_PASSWORD}" \
      -H "Content-Type: application/json" \
      --insecure \
      "${api_url}" 2>&1)
    http_code=$(echo "${response}" | tail -n1)
    response_body=$(echo "${response}" | sed '$d')
    if [[ "${http_code}" == "200" ]]; then
      token=$(echo "${response_body}" | jq -r '.token // .access_token // empty')
    fi
  fi

  # Attempt 3: GET with Basic Auth (seen on some deployments)
  if [[ -z "${token}" || "${token}" == "null" ]]; then
    log_debug "Trying GET /auth/token with Basic Auth"
    response=$(curl --max-time 15 --connect-timeout 5 -s -w "\n%{http_code}" -X GET \
      -u "${FABRIC_COMPOSER_USERNAME}:${FABRIC_COMPOSER_PASSWORD}" \
      --insecure \
      "${api_url}" 2>&1)
    http_code=$(echo "${response}" | tail -n1)
    response_body=$(echo "${response}" | sed '$d')
    if [[ "${http_code}" == "200" ]]; then
      token=$(echo "${response_body}" | jq -r '.token // .access_token // empty')
    fi
  fi

  if [[ -z "${token}" ]] || [[ "${token}" == "null" ]]; then
    log_error "Authentication failed with HTTP ${http_code}"
    log_error "Response: ${response_body}"
    _log_func_exit_fail "get_auth_token" "1"
    return 1
  fi

  # Store token
  echo "${token}" >"${TOKEN_FILE}"
  chmod 600 "${TOKEN_FILE}"

  # Calculate and store expiry time
  current_time=$(date +%s)
  expiry_time=$((current_time + DEFAULT_TOKEN_DURATION))
  echo "${expiry_time}" >"${TOKEN_EXPIRY_FILE}"

  log_success "Authentication token obtained successfully"
  log_debug "Token expires at: $(date -d "@${expiry_time}" '+%Y-%m-%d %H:%M:%S')"

  _log_func_exit_ok "get_auth_token"
  return 0
}

#######################################
# Read authentication token from file
# Outputs:
#   Writes token to stdout
# Returns:
#   0 on success, 1 on failure
#######################################
read_token() {
  _log_func_enter "read_token"

  if [[ ! -f "${TOKEN_FILE}" ]]; then
    log_error "Token file not found: ${TOKEN_FILE}"
    _log_func_exit_fail "read_token" "1"
    return 1
  fi

  cat "${TOKEN_FILE}"

  _log_func_exit_ok "read_token"
  return 0
}

#######################################
# Get fabric UUID from fabric name
# Arguments:
#   $1 - Fabric name
# Outputs:
#   Writes fabric UUID to stdout
# Returns:
#   0 on success, 1 on failure
#######################################
get_fabric_uuid() {
  _log_func_enter "get_fabric_uuid"

  local fabric_name="$1"

  if [[ -z "${fabric_name}" ]]; then
    log_error "Fabric name is required"
    _log_func_exit_fail "get_fabric_uuid" "1"
    return 1
  fi

  local token
  if ! token=$(read_token); then
    log_error "Failed to read authentication token"
    _log_func_exit_fail "get_fabric_uuid" "1"
    return 1
  fi

  local api_url="${FABRIC_COMPOSER_PROTOCOL}://${FABRIC_COMPOSER_IP}:${FABRIC_COMPOSER_PORT}/api/${API_VERSION}/fabrics"

  log_info "Searching for fabric: ${fabric_name}"

  local response
  local http_code

  response=$(curl --max-time 15 --connect-timeout 5 -s -w "\n%{http_code}" -X GET \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer ${token}" \
    --insecure \
    "${api_url}" 2>&1)

  http_code=$(echo "${response}" | tail -n1)
  local response_body
  response_body=$(echo "${response}" | sed '$d')

  log_debug "HTTP Status Code: ${http_code}"

  if [[ "${http_code}" != "200" ]]; then
    log_error "Failed to retrieve fabrics (HTTP ${http_code})"
    log_error "Response: ${response_body}"
    _log_func_exit_fail "get_fabric_uuid" "1"
    return 1
  fi

  # Search for fabric by name
  local fabric_uuid
  fabric_uuid=$(echo "${response_body}" | jq -r --arg name "${fabric_name}" '.[] | select(.name == $name) | .uuid // .id // empty' 2>/dev/null | head -n1)

  if [[ -z "${fabric_uuid}" ]] || [[ "${fabric_uuid}" == "null" ]]; then
    log_error "Fabric not found: ${fabric_name}"
    log_info "Available fabrics:"
    echo "${response_body}" | jq -r '.[] | "\(.name) (\(.uuid // .id))"' 2>/dev/null || echo "Unable to parse fabric list"
    _log_func_exit_fail "get_fabric_uuid" "1"
    return 1
  fi

  log_success "Found fabric '${fabric_name}' with UUID: ${fabric_uuid}"
  echo "${fabric_uuid}"

  _log_func_exit_ok "get_fabric_uuid"
  return 0
}

#######################################
# Get switch UUIDs from fabric
# Arguments:
#   $1 - Fabric UUID
# Outputs:
#   Writes comma-separated switch UUIDs to stdout
# Returns:
#   0 on success (even if no switches found), 1 on failure
#######################################
get_fabric_switches() {
  _log_func_enter "get_fabric_switches"

  local fabric_uuid="$1"

  if [[ -z "${fabric_uuid}" ]]; then
    log_error "Fabric UUID is required"
    _log_func_exit_fail "get_fabric_switches" "1"
    return 1
  fi

  local token
  if ! token=$(read_token); then
    log_error "Failed to read authentication token"
    _log_func_exit_fail "get_fabric_switches" "1"
    return 1
  fi

  local api_url="${FABRIC_COMPOSER_PROTOCOL}://${FABRIC_COMPOSER_IP}:${FABRIC_COMPOSER_PORT}/api/${API_VERSION}/switches?fabric_uuid=${fabric_uuid}"

  log_info "Retrieving switches for fabric UUID: ${fabric_uuid}"

  local response
  local http_code

  response=$(curl --max-time 15 --connect-timeout 5 -s -w "\n%{http_code}" -X GET \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer ${token}" \
    --insecure \
    "${api_url}" 2>&1)

  http_code=$(echo "${response}" | tail -n1)
  local response_body
  response_body=$(echo "${response}" | sed '$d')

  log_debug "HTTP Status Code: ${http_code}"

  if [[ "${http_code}" != "200" ]]; then
    log_warning "Failed to retrieve switches (HTTP ${http_code}), VRF will be created without switch assignment"
    log_debug "Response: ${response_body}"
    _log_func_exit_ok "get_fabric_switches"
    return 0
  fi

  # Extract switch UUIDs
  local switch_uuids
  switch_uuids=$(echo "${response_body}" | jq -r '[.[] | .uuid // .id] | join(",")' 2>/dev/null)

  if [[ -n "${switch_uuids}" ]] && [[ "${switch_uuids}" != "null" ]]; then
    log_success "Found switches: ${switch_uuids}"
    echo "${switch_uuids}"
  else
    log_info "No switches found in fabric"
  fi

  _log_func_exit_ok "get_fabric_switches"
  return 0
}

#######################################
# Validate VRF configuration parameters
# Returns:
#   0 if configuration is valid, 1 otherwise
#######################################
validate_vrf_config() {
  _log_func_enter "validate_vrf_config"

  local errors=0

  # Validate VRF name
  if [[ -z "${VRF_NAME}" ]]; then
    log_error "VRF name is required"
    errors=1
  elif [[ ! "${VRF_NAME}" =~ ^[a-zA-Z0-9_-]+$ ]]; then
    log_error "VRF name contains invalid characters (use alphanumeric, dash, underscore)"
    errors=1
  fi

  # Validate fabric name
  if [[ -z "${FABRIC_NAME}" ]]; then
    log_error "Fabric name is required"
    errors=1
  fi

  # Validate route distinguisher format (if provided)
  if [[ -n "${ROUTE_DISTINGUISHER}" ]]; then
    if [[ ! "${ROUTE_DISTINGUISHER}" =~ ^[0-9]+:[0-9]+$ ]]; then
      log_error "Route Distinguisher must be in format ASN:NN (e.g., 65000:100)"
      errors=1
    fi
  fi

  # Validate address family
  if [[ -n "${ADDRESS_FAMILY}" ]]; then
    IFS=',' read -ra af_array <<<"${ADDRESS_FAMILY}"
    for af in "${af_array[@]}"; do
      af=$(echo "${af}" | xargs) # trim whitespace
      if [[ "${af}" != "ipv4" ]] && [[ "${af}" != "ipv6" ]]; then
        log_error "Invalid address family: ${af} (must be ipv4 or ipv6)"
        errors=1
      fi
    done
  fi

  if [[ ${errors} -eq 1 ]]; then
    log_error "VRF configuration validation failed"
    _log_func_exit_fail "validate_vrf_config" "1"
    return 1
  fi

  log_success "VRF configuration validated successfully"
  _log_func_exit_ok "validate_vrf_config"
  return 0
}

#######################################
# Build VRF JSON payload according to AFC API specification
# Outputs:
#   Writes JSON payload to stdout
# Returns:
#   0 on success, 1 on failure
#######################################
build_vrf_payload() {
  _log_func_enter "build_vrf_payload"

  # Start with required fields: name and fabric_uuid
  local payload
  payload=$(jq -n \
    --arg name "${VRF_NAME}" \
    --arg fabric_uuid "${FABRIC_UUID}" \
    '{name: $name, fabric_uuid: $fabric_uuid}')

  # Add description if provided
  if [[ -n "${VRF_DESCRIPTION}" ]]; then
    payload=$(echo "${payload}" | jq --arg desc "${VRF_DESCRIPTION}" '. + {description: $desc}')
  fi

  # Add switch_uuids if provided
  if [[ -n "${SWITCH_UUIDS}" ]]; then
    IFS=',' read -ra switch_array <<<"${SWITCH_UUIDS}"
    local switch_json
    switch_json=$(printf '%s\n' "${switch_array[@]}" | jq -R . | jq -s .)
    payload=$(echo "${payload}" | jq --argjson switches "${switch_json}" '. + {switch_uuids: $switches}')
  fi

  # Add route_distinguisher (underscore, not hyphen)
  if [[ -n "${ROUTE_DISTINGUISHER}" ]]; then
    payload=$(echo "${payload}" | jq --arg rd "${ROUTE_DISTINGUISHER}" '. + {route_distinguisher: $rd}')
  else
    # API accepts null for route_distinguisher
    payload=$(echo "${payload}" | jq '. + {route_distinguisher: null}')
  fi

  # Build route_target object (complex structure required by API)
  if [[ -n "${ROUTE_TARGET_IMPORT}" ]] || [[ -n "${ROUTE_TARGET_EXPORT}" ]]; then
    local rt_mode="both"
    local af_value="evpn"

    # Determine route mode based on what's provided
    if [[ -n "${ROUTE_TARGET_IMPORT}" ]] && [[ -z "${ROUTE_TARGET_EXPORT}" ]]; then
      rt_mode="import"
    elif [[ -z "${ROUTE_TARGET_IMPORT}" ]] && [[ -n "${ROUTE_TARGET_EXPORT}" ]]; then
      rt_mode="export"
    fi

    # Use address family if specified, default to evpn
    if [[ -n "${ADDRESS_FAMILY}" ]]; then
      af_value="${ADDRESS_FAMILY%%,*}" # Use first AF if multiple provided
    fi

    # Build primary_route_target structure
    local route_target_obj
    route_target_obj=$(jq -n \
      --arg af "${af_value}" \
      --arg mode "${rt_mode}" \
      '{
        primary_route_target: {
          address_family: $af,
          route_mode: $mode
        }
      }')

    payload=$(echo "${payload}" | jq --argjson rt "${route_target_obj}" '. + {route_target: $rt}')
  fi

  # Add VNI if provided
  if [[ -n "${VNI}" ]]; then
    payload=$(echo "${payload}" | jq --argjson vni "${VNI}" '. + {vni: $vni}')
  fi

  # Add networks array (empty by default, can be populated later)
  payload=$(echo "${payload}" | jq '. + {networks: []}')

  # Add BGP configuration (optional, with sensible defaults)
  local bgp_config
  bgp_config=$(jq -n '{
    bestpath: true,
    fast_external_fallover: true,
    trap_enable: false,
    log_neighbor_changes: true,
    deterministic_med: true,
    always_compare_med: true
  }')
  payload=$(echo "${payload}" | jq --argjson bgp "${bgp_config}" '. + {bgp: $bgp}')

  # Add session and CPS limits
  if [[ -n "${MAX_SESSIONS_MODE}" ]]; then
    payload=$(echo "${payload}" | jq --arg mode "${MAX_SESSIONS_MODE}" '. + {max_sessions_mode: $mode}')
  fi
  if [[ -n "${MAX_CPS_MODE}" ]]; then
    payload=$(echo "${payload}" | jq --arg mode "${MAX_CPS_MODE}" '. + {max_cps_mode: $mode}')
  fi
  if [[ -n "${MAX_SESSIONS}" ]]; then
    payload=$(echo "${payload}" | jq --argjson max "${MAX_SESSIONS}" '. + {max_sessions: $max}')
  fi
  if [[ -n "${MAX_CPS}" ]]; then
    payload=$(echo "${payload}" | jq --argjson max "${MAX_CPS}" '. + {max_cps: $max}')
  fi

  echo "${payload}"

  _log_func_exit_ok "build_vrf_payload"
  return 0
}

#######################################
# Create VRF on Fabric Composer
# Returns:
#   0 on success, 1 on failure
#######################################
create_vrf() {
  _log_func_enter "create_vrf"

  log_section "CREATING VRF"

  # Get authentication token
  if ! get_auth_token; then
    log_error "Failed to obtain authentication token"
    _log_func_exit_fail "create_vrf" "1"
    return 1
  fi

  local token
  if ! token=$(read_token); then
    log_error "Failed to read authentication token"
    _log_func_exit_fail "create_vrf" "1"
    return 1
  fi

  # Get fabric UUID from fabric name
  log_info "Resolving fabric name to UUID..."
  if ! FABRIC_UUID=$(get_fabric_uuid "${FABRIC_NAME}"); then
    log_error "Failed to get fabric UUID"
    _log_func_exit_fail "create_vrf" "1"
    return 1
  fi

  # Get switch UUIDs from fabric (optional)
  if [[ -z "${SWITCH_UUIDS}" ]]; then
    log_info "Retrieving switches for fabric..."
    SWITCH_UUIDS=$(get_fabric_switches "${FABRIC_UUID}") || true
  fi

  # Build VRF payload
  local payload
  if ! payload=$(build_vrf_payload); then
    log_error "Failed to build VRF payload"
    _log_func_exit_fail "create_vrf" "1"
    return 1
  fi

  log_info "VRF Configuration:"
  echo "${payload}" | jq '.'

  # Dry run mode - just validate and exit
  if [[ "${DRY_RUN}" == "true" ]]; then
    log_info "DRY RUN mode - VRF would be created with above configuration"
    _log_func_exit_ok "create_vrf"
    return 0
  fi

  # Create VRF via API (corrected endpoint)
  local api_url="${FABRIC_COMPOSER_PROTOCOL}://${FABRIC_COMPOSER_IP}:${FABRIC_COMPOSER_PORT}/api/vrfs"

  log_info "Creating VRF '${VRF_NAME}' on fabric '${FABRIC_NAME}' (UUID: ${FABRIC_UUID})..."

  local response
  local http_code

  response=$(curl --max-time 15 --connect-timeout 5 -s -w "\n%{http_code}" -X POST \
    -H "Content-Type: application/json; version=1.0" \
    -H "Authorization: Bearer ${token}" \
    -d "${payload}" \
    --insecure \
    "${api_url}" 2>&1)

  http_code=$(echo "${response}" | tail -n1)
  local response_body
  response_body=$(echo "${response}" | sed '$d')

  log_debug "HTTP Status Code: ${http_code}"

  # Check for success (200, 201, 207 are success codes per API docs)
  if [[ "${http_code}" =~ ^20[0-9]$ ]]; then
    log_success "VRF '${VRF_NAME}' created successfully"

    if [[ "${http_code}" == "207" ]]; then
      log_warning "Partial success (HTTP 207): Some VRFs applied with RD, some were not"
    fi

    log_info "Response:"
    echo "${response_body}" | jq '.' 2>/dev/null || echo "${response_body}"

    # Extract VRF UUID
    VRF_UUID=$(echo "${response_body}" | jq -r '.uuid // .id // empty' 2>/dev/null)

    if [[ -n "${VRF_UUID}" ]] && [[ "${VRF_UUID}" != "null" ]]; then
      log_success "VRF UUID: ${VRF_UUID}"
    else
      log_info "VRF created (UUID not returned in response)"
    fi

    _log_func_exit_ok "create_vrf"
    return 0
  else
    log_error "Failed to create VRF (HTTP ${http_code})"
    log_error "Response: ${response_body}"

    # Try to extract error message from JSON response
    local error_msg
    error_msg=$(echo "${response_body}" | jq -r '.error // .message // empty' 2>/dev/null)
    if [[ -n "${error_msg}" ]]; then
      log_error "API Error: ${error_msg}"
    fi

    _log_func_exit_fail "create_vrf" "1"
    return 1
  fi
}

#######################################
# Apply/Reapply VRF configuration to Fabric Composer
# Note: The API documentation shows vrfs.reapply endpoint exists
# Returns:
#   0 on success, 1 on failure
#######################################
apply_vrf() {
  _log_func_enter "apply_vrf"

  log_section "APPLYING VRF CONFIGURATION"

  # Note: According to AFC API docs, VRF creation via POST /api/vrfs should
  # automatically apply the configuration. This function attempts to use
  # the reapply endpoint if needed, but it may not be necessary.

  # Check if VRF UUID is available
  if [[ -z "${VRF_UUID}" ]] || [[ "${VRF_UUID}" == "null" ]]; then
    log_info "VRF UUID not available - configuration should be auto-applied"
    log_info "Skipping explicit apply step"
    _log_func_exit_ok "apply_vrf"
    return 0
  fi

  # Get authentication token
  if ! get_auth_token; then
    log_error "Failed to obtain authentication token for apply"
    _log_func_exit_fail "apply_vrf" "1"
    return 1
  fi

  local token
  if ! token=$(read_token); then
    log_error "Failed to read authentication token for apply"
    _log_func_exit_fail "apply_vrf" "1"
    return 1
  fi

  # Try using vrfs.reapply endpoint (based on API docs)
  local api_url="${FABRIC_COMPOSER_PROTOCOL}://${FABRIC_COMPOSER_IP}:${FABRIC_COMPOSER_PORT}/api/${API_VERSION}/vrfs/reapply"

  log_info "Attempting to reapply VRF configuration (UUID: ${VRF_UUID})..."

  # Build reapply payload
  local reapply_payload
  reapply_payload=$(jq -n --arg uuid "${VRF_UUID}" '{vrf_uuids: [$uuid]}')

  local response
  local http_code

  response=$(curl --max-time 30 --connect-timeout 5 -s -w "\n%{http_code}" -X POST \
    -H "Content-Type: application/json; version=1.0" \
    -H "Authorization: Bearer ${token}" \
    -d "${reapply_payload}" \
    --insecure \
    "${api_url}" 2>&1)

  http_code=$(echo "${response}" | tail -n1)
  local response_body
  response_body=$(echo "${response}" | sed '$d')

  log_debug "HTTP Status Code: ${http_code}"

  # Check for success
  if [[ "${http_code}" =~ ^20[0-9]$ ]]; then
    log_success "VRF configuration reapplied successfully"
    log_info "Response:"
    echo "${response_body}" | jq '.' 2>/dev/null || echo "${response_body}"
    _log_func_exit_ok "apply_vrf"
    return 0
  else
    log_warning "Reapply endpoint returned HTTP ${http_code}"
    log_debug "Response: ${response_body}"
    log_info "VRF may already be applied automatically during creation"

    # Don't fail if reapply doesn't work - VRF might be auto-applied
    _log_func_exit_ok "apply_vrf"
    return 0
  fi
}

#######################################
# Prompt user for VRF configuration in interactive mode
# Returns:
#   0 on success, 1 on failure
#######################################
prompt_vrf_config() {
  _log_func_enter "prompt_vrf_config"

  log_section "INTERACTIVE VRF CONFIGURATION"

  # VRF Name
  read -r -p "VRF Name: " VRF_NAME
  if [[ -z "${VRF_NAME}" ]]; then
    log_error "VRF name cannot be empty"
    _log_func_exit_fail "prompt_vrf_config" "1"
    return 1
  fi

  # Fabric Name
  read -r -p "Fabric Name: " FABRIC_NAME
  if [[ -z "${FABRIC_NAME}" ]]; then
    log_error "Fabric name cannot be empty"
    _log_func_exit_fail "prompt_vrf_config" "1"
    return 1
  fi

  # Route Distinguisher
  read -r -p "Route Distinguisher (e.g., 65000:100) [optional]: " ROUTE_DISTINGUISHER

  # Route Target Import
  read -r -p "Route Target Import (comma-separated) [optional]: " ROUTE_TARGET_IMPORT

  # Route Target Export
  read -r -p "Route Target Export (comma-separated) [optional]: " ROUTE_TARGET_EXPORT

  # Address Family
  read -r -p "Address Family (ipv4, ipv6, or both) [default: ipv4]: " ADDRESS_FAMILY
  ADDRESS_FAMILY="${ADDRESS_FAMILY:-ipv4}"

  # Description
  read -r -p "Description [optional]: " VRF_DESCRIPTION

  _log_func_exit_ok "prompt_vrf_config"
  return 0
}

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
    -i | --interactive)
      INTERACTIVE_MODE=true
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
    -f | --fabric)
      FABRIC_NAME="$2"
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
    -v | --vni)
      VNI="$2"
      shift 2
      ;;
    -s | --switches)
      SWITCH_UUIDS="$2"
      shift 2
      ;;
    --max-sessions-mode)
      MAX_SESSIONS_MODE="$2"
      shift 2
      ;;
    --max-cps-mode)
      MAX_CPS_MODE="$2"
      shift 2
      ;;
    --max-sessions)
      MAX_SESSIONS="$2"
      shift 2
      ;;
    --max-cps)
      MAX_CPS="$2"
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
    --no-install)
      NO_INSTALL=true
      shift
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

  log_section "HPE ARUBA FABRIC COMPOSER - VRF CREATION"

  # Check dependencies
  if ! check_dependencies; then
    log_error "Dependency check failed"
    _log_func_exit_fail "main" "1"
    exit 1
  fi

  # Validate session limits modes
  if [[ "${MAX_SESSIONS_MODE}" != "unlimited" && "${MAX_SESSIONS_MODE}" != "limited" ]]; then
    log_error "Invalid max_sessions_mode: ${MAX_SESSIONS_MODE} (must be 'unlimited' or 'limited')"
    errors=1
  fi
  if [[ "${MAX_CPS_MODE}" != "unlimited" && "${MAX_CPS_MODE}" != "limited" ]]; then
    log_error "Invalid max_cps_mode: ${MAX_CPS_MODE} (must be 'unlimited' or 'limited')"
    errors=1
  fi

  if [[ "${MAX_SESSIONS_MODE}" == "limited" && -z "${MAX_SESSIONS}" ]]; then
    log_error "max_sessions must be provided when max_sessions_mode is 'limited'"
    errors=1
  fi
  if [[ "${MAX_CPS_MODE}" == "limited" && -z "${MAX_CPS}" ]]; then
    log_error "max_cps must be provided when max_cps_mode is 'limited'"
    errors=1
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

  # Validate environment
  if ! validate_environment; then
    log_error "Environment validation failed"
    _log_func_exit_fail "main" "1"
    exit 1
  fi

  # Interactive mode - prompt for configuration
  if [[ "${INTERACTIVE_MODE}" == "true" ]]; then
    if ! prompt_vrf_config; then
      log_error "Failed to collect VRF configuration"
      _log_func_exit_fail "main" "1"
      exit 1
    fi
  fi

  # Validate VRF configuration
  if ! validate_vrf_config; then
    log_error "VRF configuration validation failed"
    _log_func_exit_fail "main" "1"
    exit 1
  fi

  # Create VRF
  if ! create_vrf; then
    log_error "VRF creation failed"
    _log_func_exit_fail "main" "1"
    exit 1
  fi

  # Apply VRF configuration (skip in dry-run mode)
  if [[ "${DRY_RUN}" != "true" ]]; then
    if ! apply_vrf; then
      log_warning "VRF created but apply step failed"
      log_info "You may need to manually apply the VRF configuration"
      _log_func_exit_fail "main" "1"
      exit 1
    fi
  fi

  log_section "OPERATION COMPLETED"
  log_success "VRF creation and application completed successfully"

  _log_func_exit_ok "main"
  exit 0
}

# Execute main only if script is called directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi
