#!/bin/bash
################################################################################
# Script: test-vrf-creation.sh
# Description: Test script for VRF creation with Fabric Composer
################################################################################

# Load environment
# shellcheck disable=SC1091
source .env

# Test 1: Dry-run mode (validate without creating)
echo "========== TEST 1: DRY RUN =========="
./create-aruba-vrf.sh \
  --env-file .env \
  --name TEST-VRF-01 \
  --fabric default \
  --rd 65000:100 \
  --rt-import "65000:100" \
  --rt-export "65000:100" \
  --af ipv4 \
  --description "Test VRF - Dry Run" \
  --dry-run

echo ""
echo "========== DRY RUN COMPLETED =========="
echo ""
echo "To create VRF for real, run:"
echo ""
echo "./create-aruba-vrf.sh \\"
echo "  --env-file .env \\"
echo "  --name TEST-VRF-01 \\"
echo "  --fabric default \\"
echo "  --rd 65000:100 \\"
echo "  --rt-import \"65000:100\" \\"
echo "  --rt-export \"65000:100\" \\"
echo "  --af ipv4 \\"
echo "  --description \"Test VRF\""
echo ""
