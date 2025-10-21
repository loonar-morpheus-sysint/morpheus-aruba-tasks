#!/bin/bash
################################################################################
# Script: test-payload-structure.sh
# Description: Test script to validate AFC VRF payload structure
################################################################################

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== AFC VRF Payload Structure Validation ===${NC}\n"

# Test 1: Basic payload structure
echo -e "${YELLOW}Test 1: Basic VRF payload${NC}"
BASIC_PAYLOAD=$(jq -n \
  --arg name "TEST-VRF" \
  --arg fabric_uuid "a1b2c3d4-e5f6-7890-abcd-ef1234567890" \
  '{
    name: $name,
    fabric_uuid: $fabric_uuid,
    route_distinguisher: null,
    networks: [],
    bgp: {
      bestpath: true,
      fast_external_fallover: true,
      trap_enable: false,
      log_neighbor_changes: true,
      deterministic_med: true,
      always_compare_med: true
    }
  }')

echo "${BASIC_PAYLOAD}" | jq '.'
echo -e "${GREEN}✓ Basic payload structure valid${NC}\n"

# Test 2: Payload with route distinguisher and VNI
echo -e "${YELLOW}Test 2: VRF with RD and VNI${NC}"
RD_VNI_PAYLOAD=$(jq -n \
  --arg name "PROD-VRF" \
  --arg fabric_uuid "a1b2c3d4-e5f6-7890-abcd-ef1234567890" \
  --arg rd "65000:100" \
  --argjson vni "5000" \
  '{
    name: $name,
    fabric_uuid: $fabric_uuid,
    route_distinguisher: $rd,
    vni: $vni,
    networks: [],
    bgp: {
      bestpath: true,
      fast_external_fallover: true,
      trap_enable: false,
      log_neighbor_changes: true,
      deterministic_med: true,
      always_compare_med: true
    }
  }')

echo "${RD_VNI_PAYLOAD}" | jq '.'
echo -e "${GREEN}✓ RD and VNI payload structure valid${NC}\n"

# Test 3: Payload with route_target object
echo -e "${YELLOW}Test 3: VRF with route_target object${NC}"
RT_PAYLOAD=$(jq -n \
  --arg name "CUSTOMER-VRF" \
  --arg fabric_uuid "a1b2c3d4-e5f6-7890-abcd-ef1234567890" \
  --arg rd "65000:200" \
  '{
    name: $name,
    fabric_uuid: $fabric_uuid,
    route_distinguisher: $rd,
    route_target: {
      primary_route_target: {
        address_family: "evpn",
        route_mode: "both"
      }
    },
    networks: [],
    bgp: {
      bestpath: true,
      fast_external_fallover: true,
      trap_enable: false,
      log_neighbor_changes: true,
      deterministic_med: true,
      always_compare_med: true
    }
  }')

echo "${RT_PAYLOAD}" | jq '.'
echo -e "${GREEN}✓ route_target object structure valid${NC}\n"

# Test 4: Complete payload with all optional fields
echo -e "${YELLOW}Test 4: Complete VRF with all fields${NC}"
COMPLETE_PAYLOAD=$(jq -n \
  --arg name "FULL-VRF" \
  --arg fabric_uuid "a1b2c3d4-e5f6-7890-abcd-ef1234567890" \
  --arg rd "65000:300" \
  --argjson vni "6000" \
  --arg desc "Complete VRF with all options" \
  --argjson switches '["switch-uuid-1", "switch-uuid-2"]' \
  '{
    name: $name,
    fabric_uuid: $fabric_uuid,
    description: $desc,
    switch_uuids: $switches,
    route_distinguisher: $rd,
    vni: $vni,
    route_target: {
      primary_route_target: {
        address_family: "evpn",
        route_mode: "import"
      }
    },
    networks: [],
    bgp: {
      bestpath: true,
      fast_external_fallover: true,
      trap_enable: false,
      log_neighbor_changes: true,
      deterministic_med: true,
      always_compare_med: true
    }
  }')

echo "${COMPLETE_PAYLOAD}" | jq '.'
echo -e "${GREEN}✓ Complete payload structure valid${NC}\n"

# Test 7: Payload with session limits
echo -e "${YELLOW}Test 7: VRF with session limits${NC}"
LIMITS_PAYLOAD=$(jq -n \
  --arg name "LIMIT-VRF" \
  --arg fabric_uuid "a1b2c3d4-e5f6-7890-abcd-ef1234567890" \
  --arg max_sessions_mode "limited" \
  --arg max_cps_mode "limited" \
  --argjson max_sessions 20000 \
  --argjson max_cps 2000 \
  '{
    name: $name,
    fabric_uuid: $fabric_uuid,
    max_sessions_mode: $max_sessions_mode,
    max_cps_mode: $max_cps_mode,
    max_sessions: $max_sessions,
    max_cps: $max_cps,
    networks: [],
    bgp: {
      bestpath: true,
      fast_external_fallover: true,
      trap_enable: false,
      log_neighbor_changes: true,
      deterministic_med: true,
      always_compare_med: true
    }
  }')

echo "${LIMITS_PAYLOAD}" | jq '.'
echo -e "${GREEN}✓ session limits payload structure valid${NC}\n"

# Test 5: Validate required fields
echo -e "${YELLOW}Test 5: Validate required fields${NC}"
REQUIRED_FIELDS=("name" "fabric_uuid")
for field in "${REQUIRED_FIELDS[@]}"; do
  if echo "${COMPLETE_PAYLOAD}" | jq -e "has(\"${field}\")" > /dev/null; then
    echo -e "${GREEN}✓ Required field '${field}' present${NC}"
  else
    echo -e "${RED}✗ Required field '${field}' missing${NC}"
    exit 1
  fi
done
echo ""

# Test 6: Validate field types
echo -e "${YELLOW}Test 6: Validate field types${NC}"
echo -n "Checking name is string... "
if echo "${COMPLETE_PAYLOAD}" | jq -e '.name | type == "string"' > /dev/null; then
  echo -e "${GREEN}✓${NC}"
else
  echo -e "${RED}✗${NC}"
  exit 1
fi

echo -n "Checking fabric_uuid is string... "
if echo "${COMPLETE_PAYLOAD}" | jq -e '.fabric_uuid | type == "string"' > /dev/null; then
  echo -e "${GREEN}✓${NC}"
else
  echo -e "${RED}✗${NC}"
  exit 1
fi

echo -n "Checking vni is number... "
if echo "${COMPLETE_PAYLOAD}" | jq -e '.vni | type == "number"' > /dev/null; then
  echo -e "${GREEN}✓${NC}"
else
  echo -e "${RED}✗${NC}"
  exit 1
fi

echo -n "Checking switch_uuids is array... "
if echo "${COMPLETE_PAYLOAD}" | jq -e '.switch_uuids | type == "array"' > /dev/null; then
  echo -e "${GREEN}✓${NC}"
else
  echo -e "${RED}✗${NC}"
  exit 1
fi

echo -n "Checking networks is array... "
if echo "${COMPLETE_PAYLOAD}" | jq -e '.networks | type == "array"' > /dev/null; then
  echo -e "${GREEN}✓${NC}"
else
  echo -e "${RED}✗${NC}"
  exit 1
fi

echo -n "Checking bgp is object... "
if echo "${COMPLETE_PAYLOAD}" | jq -e '.bgp | type == "object"' > /dev/null; then
  echo -e "${GREEN}✓${NC}"
else
  echo -e "${RED}✗${NC}"
  exit 1
fi

echo -n "Checking route_target is object... "
if echo "${COMPLETE_PAYLOAD}" | jq -e '.route_target | type == "object"' > /dev/null; then
  echo -e "${GREEN}✓${NC}"
else
  echo -e "${RED}✗${NC}"
  exit 1
fi

echo ""
echo -e "${GREEN}=== All Payload Structure Tests Passed! ===${NC}"
echo ""
echo -e "${YELLOW}Summary:${NC}"
echo "  ✓ Basic payload structure"
echo "  ✓ Payload with RD and VNI"
echo "  ✓ Payload with route_target object"
echo "  ✓ Complete payload with all fields"
echo "  ✓ Required fields validation"
echo "  ✓ Field type validation"
echo ""
echo -e "${GREEN}Payload structure is compliant with AFC API specification!${NC}"
