#!/bin/bash
################################################################################
# Script: example-create-vrf.sh
# Description: Example script demonstrating create-aruba-vrf.sh usage
################################################################################
#
# This example script demonstrates how to use create-aruba-vrf.sh
# in different scenarios: interactive, CI/CD, and with custom configurations.
#
################################################################################

# SCRIPT_DIR is reserved for future use
# shellcheck disable=SC2034
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=================================="
echo "VRF Creation Examples"
echo "=================================="
echo ""

# Example 1: Interactive Mode
echo "Example 1: Interactive Mode"
echo "----------------------------"
echo "Command:"
echo "  /../scripts/hybrid/create-aruba-vrf.sh --interactive"
echo ""
echo "This will prompt you for all VRF parameters interactively."
echo ""

# Example 2: Basic VRF Creation
echo "Example 2: Basic VRF Creation"
echo "----------------------------"
echo "Command:"
cat << 'EOF'
  export FABRIC_COMPOSER_IP="10.0.0.1"
  export FABRIC_COMPOSER_USERNAME="admin"
  export FABRIC_COMPOSER_PASSWORD="secure_password"  # pragma: allowlist secret

  ./scripts/hybrid/create-aruba-vrf.sh \
    --name BASIC-VRF \
    --fabric dc1-fabric \
    --rd 65000:100
EOF
echo ""

# Example 3: Full-Featured VRF
echo "Example 3: Full-Featured VRF with Route Targets"
echo "----------------------------"
echo "Command:"
cat << 'EOF'
  ./scripts/hybrid/create-aruba-vrf.sh \
    --name PROD-VRF \
    --fabric production-fabric \
    --rd 65000:200 \
    --rt-import "65000:200,65000:201,65000:202" \
    --rt-export "65000:200,65000:201" \
    --af "ipv4,ipv6" \
    --description "Production VRF for customer XYZ with dual-stack support"
EOF
echo ""

# Example 4: Using .env File
echo "Example 4: Using .env File"
echo "----------------------------"
echo "Step 1: Create .env file:"
cat << 'EOF'
  cat > prod.env << 'ENVFILE'
  FABRIC_COMPOSER_IP=192.168.1.100
  FABRIC_COMPOSER_USERNAME=prod-admin
  FABRIC_COMPOSER_PASSWORD=prod_secure_pass
  FABRIC_COMPOSER_PORT=8443
  FABRIC_COMPOSER_PROTOCOL=https
  TOKEN_REFRESH_MARGIN=600
  ENVFILE
EOF
echo ""
echo "Step 2: Use the .env file:"
cat << 'EOF'
  ./scripts/hybrid/create-aruba-vrf.sh \
    --env-file prod.env \
    --name CUSTOMER-A-VRF \
    --fabric customer-a-fabric \
    --rd 65000:300
EOF
echo ""

# Example 5: Dry-Run Mode
echo "Example 5: Dry-Run Mode (Validation Only)"
echo "----------------------------"
echo "Command:"
cat << 'EOF'
  ./scripts/hybrid/create-aruba-vrf.sh \
    --name TEST-VRF \
    --fabric test-fabric \
    --rd 65000:999 \
    --rt-import "65000:999" \
    --rt-export "65000:999" \
    --dry-run
EOF
echo ""

# Example 6: Multiple VRFs in Loop
echo "Example 6: Creating Multiple VRFs (Automation)"
echo "----------------------------"
echo "Script:"
cat << 'EOF'
  #!/bin/bash

  # List of VRFs to create
  VRF_LIST=(
    "CUST-A-VRF:customer-a-fabric:65000:100"
    "CUST-B-VRF:customer-b-fabric:65000:200"
    "CUST-C-VRF:customer-c-fabric:65000:300"
  )

  for vrf_config in "${VRF_LIST[@]}"; do
    IFS=':' read -r name fabric asn id <<< "${vrf_config}"

    echo "Creating VRF: ${name}"
    ./scripts/hybrid/create-aruba-vrf.sh \
      --name "${name}" \
      --fabric "${fabric}" \
      --rd "${asn}:${id}" \
      --rt-import "${asn}:${id}" \
      --rt-export "${asn}:${id}"

    echo "---"
  done
EOF
echo ""

# Example 7: With Error Handling
echo "Example 7: With Error Handling"
echo "----------------------------"
echo "Script:"
cat << 'EOF'
  #!/bin/bash

  if ! ./scripts/hybrid/create-aruba-vrf.sh \
    --name IMPORTANT-VRF \
    --fabric critical-fabric \
    --rd 65000:500; then

    echo "ERROR: Failed to create VRF"
    echo "Sending alert..."
    # Send alert (email, Slack, etc.)
    exit 1
  else
    echo "SUCCESS: VRF created successfully"
    # Continue with next steps
  fi
EOF
echo ""

# Example 8: Integration with Ansible
echo "Example 8: Integration with Ansible"
echo "----------------------------"
echo "Playbook:"
cat << 'EOF'
  ---
  - name: Create VRF using Bash script
    hosts: localhost
    vars:
      vrf_name: "ANSIBLE-VRF"
      fabric_name: "ansible-fabric"
      route_distinguisher: "65000:100"

    tasks:
      - name: Create VRF on Fabric Composer
        command: >
          ./scripts/hybrid/create-aruba-vrf.sh
          --name {{ vrf_name }}
          --fabric {{ fabric_name }}
          --rd {{ route_distinguisher }}
        environment:
          FABRIC_COMPOSER_IP: "{{ fabric_composer_ip }}"
          FABRIC_COMPOSER_USERNAME: "{{ fabric_composer_username }}"
          FABRIC_COMPOSER_PASSWORD: "{{ fabric_composer_password }}"
        register: vrf_result

      - name: Show result
        debug:
          var: vrf_result.stdout
EOF
echo ""

# Example 9: Jenkins Pipeline
echo "Example 9: Jenkins Pipeline Integration"
echo "----------------------------"
echo "Jenkinsfile:"
cat << 'EOF'
  pipeline {
      agent any

      environment {
          FABRIC_COMPOSER_IP = credentials('fabric-composer-ip')
          FABRIC_COMPOSER_USERNAME = credentials('fabric-composer-username')
          FABRIC_COMPOSER_PASSWORD = credentials('fabric-composer-password')
      }

      parameters {
          string(name: 'VRF_NAME', defaultValue: 'JENKINS-VRF')
          string(name: 'FABRIC_NAME', defaultValue: 'jenkins-fabric')
          string(name: 'ROUTE_DISTINGUISHER', defaultValue: '65000:100')
      }

      stages {
          stage('Validate') {
              steps {
                  sh '''
                      ./scripts/hybrid/create-aruba-vrf.sh \
                        --name ${VRF_NAME} \
                        --fabric ${FABRIC_NAME} \
                        --rd ${ROUTE_DISTINGUISHER} \
                        --dry-run
                  '''
              }
          }

          stage('Create VRF') {
              steps {
                  sh '''
                      ./scripts/hybrid/create-aruba-vrf.sh \
                        --name ${VRF_NAME} \
                        --fabric ${FABRIC_NAME} \
                        --rd ${ROUTE_DISTINGUISHER}
                  '''
              }
          }
      }
  }
EOF
echo ""

# Example 10: Docker Container
echo "Example 10: Running in Docker Container"
echo "----------------------------"
echo "Dockerfile:"
cat << 'EOF'
  FROM ubuntu:22.04

  RUN apt-get update && \
      apt-get install -y curl jq && \
      rm -rf /var/lib/apt/lists/*

  COPY create-aruba-vrf.sh /usr/local/bin/
  COPY commons.sh /usr/local/bin/

  RUN chmod +x /usr/local/bin/create-aruba-vrf.sh

  ENTRYPOINT ["/usr/local/bin/create-aruba-vrf.sh"]
EOF
echo ""
echo "Build and run:"
cat << 'EOF'
  docker build -t aruba-vrf-creator .

  docker run --rm \
    -e FABRIC_COMPOSER_IP="10.0.0.1" \
    -e FABRIC_COMPOSER_USERNAME="admin" \
    -e FABRIC_COMPOSER_PASSWORD="password" \  # pragma: allowlist secret
    aruba-vrf-creator \
    --name DOCKER-VRF \
    --fabric docker-fabric \
    --rd 65000:100
EOF
echo ""

echo "=================================="
echo "For more information, see:"
echo "  - CREATE_ARUBA_VRF.md"
echo "  - ./scripts/hybrid/create-aruba-vrf.sh --help"
echo "=================================="
