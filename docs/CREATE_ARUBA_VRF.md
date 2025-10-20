# create-aruba-vrf.sh - Documentation

## Overview

Advanced Bash script for automated VRF (Virtual Routing and Forwarding) creation on HPE Aruba Networking Fabric Composer using the REST API.

## Features

✅ **Automated Authentication**

- Automatic token acquisition via API
- Token caching and intelligent refresh (default: 30min)
- Configurable refresh margin (default: 5min before expiry)

✅ **Flexible Operation Modes**

- **Interactive Mode**: User-friendly prompts for all parameters
- **CI/CD Mode**: Full automation via command-line arguments
- **Dry-Run Mode**: Validate configuration without creating VRF

✅ **Comprehensive VRF Support**

- Route Distinguisher (RD) configuration
- Route Target Import/Export (comma-separated lists)
- Address Family support (IPv4, IPv6, or both)
- Custom descriptions and metadata

✅ **Enterprise-Grade Reliability**

- Full input validation and error handling
- Structured logging (syslog integration)
- Dependency checking (curl, jq, date)
- Environment variable validation
- HTTP status code handling

## Prerequisites

### Required Dependencies

```bash
# Install required tools
sudo apt-get update
sudo apt-get install -y curl jq coreutils

# Verify installation
curl --version
jq --version
date --version
```

### Required Environment Variables

```bash
# Option 1: Export directly
export FABRIC_COMPOSER_IP="10.0.0.1"
export FABRIC_COMPOSER_USERNAME="admin"
export FABRIC_COMPOSER_PASSWORD="your_password"  # pragma: allowlist secret

# Option 2: Use .env file (recommended)
cp .env.example .env
# Edit .env with your credentials
```

## Usage

### Interactive Mode

Best for manual/exploratory VRF creation:

```bash
./scripts/hybrid/create-aruba-vrf.sh --interactive
```

You will be prompted for:

- VRF Name
- Fabric Name
- Route Distinguisher (optional)
- Route Target Import (optional)
- Route Target Export (optional)
- Address Family (default: ipv4)
- Description (optional)

### CI/CD Mode

Best for automation and scripting:

```bash
# Minimal VRF creation
./scripts/hybrid/create-aruba-vrf.sh \
  --name PROD-VRF \
  --fabric dc1-fabric \
  --rd 65000:100

# Full-featured VRF
./scripts/hybrid/create-aruba-vrf.sh \
  --name CUSTOMER-A-VRF \
  --fabric dc1-fabric \
  --rd 65000:100 \
  --rt-import "65000:100,65000:200,65000:300" \
  --rt-export "65000:100,65000:200" \
  --af "ipv4,ipv6" \
  --description "Customer A Production VRF"
```

### Using .env File

```bash
# Load credentials from custom .env file
./scripts/hybrid/create-aruba-vrf.sh \
  --env-file /path/to/prod.env \
  --name PROD-VRF \
  --fabric dc1-fabric \
  --rd 65000:100
```

### Dry-Run Mode

Validate configuration without creating VRF:

```bash
./scripts/hybrid/create-aruba-vrf.sh \
  --name TEST-VRF \
  --fabric dc1-fabric \
  --rd 65000:100 \
  --dry-run
```

## Command-Line Options

| Option | Short | Description | Required |
|--------|-------|-------------|----------|
| `--help` | `-h` | Show help message | No |
| `--interactive` | `-i` | Run in interactive mode | No |
| `--env-file FILE` | `-e` | Load environment from FILE | No |
| `--name NAME` | `-n` | VRF name | Yes |
| `--fabric FABRIC` | `-f` | Fabric name | Yes |
| `--rd RD` | `-r` | Route Distinguisher (ASN:NN) | No |
| `--rt-import RT` | `-I` | Route Target Import (comma-separated) | No |
| `--rt-export RT` | `-E` | Route Target Export (comma-separated) | No |
| `--af FAMILY` | `-a` | Address Family (ipv4, ipv6, or both) | No |
| `--description DESC` | `-d` | VRF description | No |
| `--dry-run` | - | Validate without creating | No |

## Environment Variables

### Required

| Variable | Description | Example |
|----------|-------------|---------|
| `FABRIC_COMPOSER_IP` | Fabric Composer IP/hostname | `10.0.0.1` |
| `FABRIC_COMPOSER_USERNAME` | API username | `admin` |
| `FABRIC_COMPOSER_PASSWORD` | API password | `secure_password` |

### Optional

| Variable | Description | Default |
|----------|-------------|---------|
| `FABRIC_COMPOSER_PORT` | API port | `443` |
| `FABRIC_COMPOSER_PROTOCOL` | Protocol (http/https) | `https` |
| `TOKEN_REFRESH_MARGIN` | Seconds before expiry to refresh | `300` |
| `LOG_VIEW` | Log levels to display | All levels |

## Examples

### Example 1: Basic VRF

```bash
./scripts/hybrid/create-aruba-vrf.sh \
  --name BASIC-VRF \
  --fabric my-fabric \
  --rd 65000:100
```

### Example 2: VRF with Route Targets

```bash
./scripts/hybrid/create-aruba-vrf.sh \
  --name ADVANCED-VRF \
  --fabric my-fabric \
  --rd 65000:200 \
  --rt-import "65000:200,65000:201" \
  --rt-export "65000:200"
```

### Example 3: Dual-Stack VRF

```bash
./scripts/hybrid/create-aruba-vrf.sh \
  --name DUALSTACK-VRF \
  --fabric my-fabric \
  --rd 65000:300 \
  --af "ipv4,ipv6" \
  --description "Dual-stack VRF for modern applications"
```

### Example 4: Using Environment File

```bash
# Create production .env file
cat > prod.env << 'EOF'
FABRIC_COMPOSER_IP=192.168.1.100
FABRIC_COMPOSER_USERNAME=prod-admin
FABRIC_COMPOSER_PASSWORD=prod_secure_pass
FABRIC_COMPOSER_PORT=8443
EOF

# Use it
./scripts/hybrid/create-aruba-vrf.sh \
  --env-file prod.env \
  --name PROD-VRF-001 \
  --fabric prod-fabric \
  --rd 65000:1001
```

### Example 5: Dry-Run Validation

```bash
# Test configuration before applying
./scripts/hybrid/create-aruba-vrf.sh \
  --name TEST-VRF \
  --fabric test-fabric \
  --rd 65000:999 \
  --rt-import "65000:999,65000:998" \
  --dry-run
```

## API Endpoints Used

### Authentication

```http
POST /api/v1/auth/token
Body: {"username": "...", "password": "..."}
Response: {"token": "...", ...}
```

### VRF Creation

```http
POST /api/v1/vrfs
Headers: Authorization: Bearer <token>
Body: {
  "name": "...",
  "fabric": "...",
  "route-distinguisher": "...",
  "route-target-import": [...],
  "route-target-export": [...],
  "address-family": [...],
  "description": "..."
}
```

## Token Management

The script implements intelligent token management:

1. **Token Caching**: Stores token in `.afc_token` file
2. **Expiry Tracking**: Stores expiry time in `.afc_token_expiry`
3. **Auto-Refresh**: Refreshes token before expiry (configurable margin)
4. **Default Duration**: 30 minutes (1800 seconds)
5. **Refresh Margin**: 5 minutes before expiry (300 seconds, configurable)

Token files are stored in the script directory with restricted permissions (600).

## Error Handling

The script validates:

✅ All required dependencies (curl, jq, date)
✅ Environment variables (FABRIC_COMPOSER_IP, USERNAME, PASSWORD)
✅ VRF name format (alphanumeric, dash, underscore only)
✅ Route Distinguisher format (ASN:NN)
✅ Address Family values (ipv4, ipv6 only)
✅ API responses and HTTP status codes

## Logging

The script uses the commons.sh logging system with syslog integration:

- **DEBUG**: Function entry/exit, detailed operations
- **INFO**: Normal operations, progress updates
- **NOTICE**: Important events, successful operations
- **WARN**: Warnings, deprecated features
- **ERROR**: Errors, failures
- **CRITICAL**: Critical failures

Configure visible log levels via `LOG_VIEW` environment variable.

## Troubleshooting

### Authentication Failures

```bash
# Check credentials
echo $FABRIC_COMPOSER_IP
echo $FABRIC_COMPOSER_USERNAME

```bash
# Test API manually
curl -k -X POST \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"password"}' \  # pragma: allowlist secret
  https://${FABRIC_COMPOSER_IP}:443/api/v1/auth/token
```

### Connection Issues

```bash
# Test connectivity
ping ${FABRIC_COMPOSER_IP}

# Test port
nc -zv ${FABRIC_COMPOSER_IP} 443

# Check SSL/TLS
openssl s_client -connect ${FABRIC_COMPOSER_IP}:443
```

### Token Issues

```bash
# Remove cached token
rm .afc_token .afc_token_expiry

# Run again
./scripts/hybrid/create-aruba-vrf.sh --name TEST-VRF --fabric test
```

### Debug Mode

```bash
# Enable debug logging
export LOG_VIEW="debug,info,notice,warn,err,crit,alert,emerg"

./scripts/hybrid/create-aruba-vrf.sh --name DEBUG-VRF --fabric test
```

## Integration Examples

### Ansible Integration

```yaml
---
- name: Create VRF using script
  hosts: localhost
  vars:
    vrf_config:
      name: "ANSIBLE-VRF"
      fabric: "ansible-fabric"
      rd: "65000:100"
  tasks:
    - name: Create VRF
      command: >
        ./scripts/hybrid/create-aruba-vrf.sh
        --name {{ vrf_config.name }}
        --fabric {{ vrf_config.fabric }}
        --rd {{ vrf_config.rd }}
      environment:
        FABRIC_COMPOSER_IP: "{{ fabric_composer_ip }}"
        FABRIC_COMPOSER_USERNAME: "{{ fabric_composer_username }}"
        FABRIC_COMPOSER_PASSWORD: "{{ fabric_composer_password }}"
```

### Jenkins Pipeline

```groovy
pipeline {
    agent any
    environment {
        FABRIC_COMPOSER_IP = credentials('fabric-composer-ip')
        FABRIC_COMPOSER_USERNAME = credentials('fabric-composer-username')
        FABRIC_COMPOSER_PASSWORD = credentials('fabric-composer-password')
    }
    stages {
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
```

### GitLab CI/CD

```yaml
create_vrf:
  stage: deploy
  script:
    - export FABRIC_COMPOSER_IP="${FABRIC_COMPOSER_IP}"
    - export FABRIC_COMPOSER_USERNAME="${FABRIC_COMPOSER_USERNAME}"
    - export FABRIC_COMPOSER_PASSWORD="${FABRIC_COMPOSER_PASSWORD}"
    - |
      ./scripts/hybrid/create-aruba-vrf.sh \
        --name ${VRF_NAME} \
        --fabric ${FABRIC_NAME} \
        --rd ${ROUTE_DISTINGUISHER}
  only:
    - main
```

## References

- [AFC API Getting Started](https://developer.arubanetworks.com/afc/docs/getting-started-with-the-afc-api)
- [VRF Documentation](https://arubanetworking.hpe.com/techdocs/AFC/700/Content/afc70olh/add-vrf.htm)
- [Authentication API](https://developer.arubanetworks.com/afc/reference/getapikey-1)
- [Ansible Collection](https://github.com/aruba/hpeanfc-ansible-collection)

## License

See LICENSE file in the repository root.

## Support

For issues and questions:

- Review CONTRIBUTING.md for contribution guidelines
- Check TROUBLESHOOTING.md for common issues
- Open an issue on GitHub repository
