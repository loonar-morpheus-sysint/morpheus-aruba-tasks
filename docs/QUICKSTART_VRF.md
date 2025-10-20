# create-aruba-vrf.sh - Quick Start

## 🚀 Quick Start

### Prerequisites

```bash
# Install dependencies
sudo apt-get install -y curl jq

# Configure environment
export FABRIC_COMPOSER_IP="10.0.0.1"
export FABRIC_COMPOSER_USERNAME="admin"
export FABRIC_COMPOSER_PASSWORD="your_password"  # pragma: allowlist secret
```

### Basic Usage

```bash
# Interactive mode (easiest for getting started)
./scripts/hybrid/create-aruba-vrf.sh --interactive

# Command-line mode (for automation)
./scripts/hybrid/create-aruba-vrf.sh \
  --name MY-VRF \
  --fabric my-fabric \
  --rd 65000:100
```

## 📋 Common Use Cases

### 1. Simple VRF

```bash
./scripts/hybrid/create-aruba-vrf.sh \
  --name SIMPLE-VRF \
  --fabric datacenter-1 \
  --rd 65000:100
```

### 2. VRF with Route Targets

```bash
./scripts/hybrid/create-aruba-vrf.sh \
  --name ADV-VRF \
  --fabric datacenter-1 \
  --rd 65000:200 \
  --rt-import "65000:200,65000:201" \
  --rt-export "65000:200"
```

### 3. Dual-Stack VRF (IPv4 + IPv6)

```bash
./scripts/hybrid/create-aruba-vrf.sh \
  --name DUALSTACK-VRF \
  --fabric datacenter-1 \
  --rd 65000:300 \
  --af "ipv4,ipv6"
```

### 4. Using .env File

```bash
# Create .env file
cat > .env << EOF
FABRIC_COMPOSER_IP=10.0.0.1
FABRIC_COMPOSER_USERNAME=admin
FABRIC_COMPOSER_PASSWORD=secure_pass
EOF

# Use it
./scripts/hybrid/create-aruba-vrf.sh \
  --env-file .env \
  --name ENV-VRF \
  --fabric datacenter-1 \
  --rd 65000:400
```

### 5. Dry-Run (Test Configuration)

```bash
./scripts/hybrid/create-aruba-vrf.sh \
  --name TEST-VRF \
  --fabric test-fabric \
  --rd 65000:999 \
  --dry-run
```

## 🔧 Troubleshooting

### Check Dependencies

```bash
# Verify required tools are installed
curl --version
jq --version
date --version
```

### Test Connectivity

```bash
# Test API connectivity
curl -k "https://${FABRIC_COMPOSER_IP}:443/api/v1/auth/token"
```

### Enable Debug Logging

```bash
# See all debug information
export LOG_VIEW="debug,info,notice,warn,err,crit,alert,emerg"
./scripts/hybrid/create-aruba-vrf.sh --name DEBUG-VRF --fabric test
```

### Clear Cached Token

```bash
# Remove cached authentication token
rm -f .afc_token .afc_token_expiry
```

## 📖 Full Documentation

For complete documentation, see:

- **[CREATE_ARUBA_VRF.md](CREATE_ARUBA_VRF.md)** - Complete documentation
- **[example-scripts/aruba/vrf/create-vrf.sh](example-scripts/aruba/vrf/create-vrf.sh)** - Usage examples
- **[.env.example](.env.example)** - Environment configuration template

## 🔐 Security Notes

- Never commit `.env` files with real credentials to version control
- Token files (`.afc_token*`) are automatically created with restricted permissions (600)
- Use environment variables or secure vaults (HashiCorp Vault, AWS Secrets Manager) in production
- The script uses `--insecure` for curl by default (suitable for lab environments)

## 📞 Help

```bash
# Show help
./scripts/hybrid/create-aruba-vrf.sh --help

# Run examples
./example-scripts/aruba/vrf/create-vrf.sh
```

## ✅ Testing

```bash
# Run tests
bats tests/test_create-aruba-vrf.bats

# Validate script with shellcheck
shellcheck scripts/hybrid/create-aruba-vrf.sh
```
