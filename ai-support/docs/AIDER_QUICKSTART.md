# 🤖 Aider — Quick Start (AI Powered)

## Start Aider (AI assisted CLI)

```bash
# Basic usage
aider

# With specific files
aider commons.sh create-vrf.sh

# With project context
aider AGENTS.md commons.sh
```

## Common Commands

Inside Aider prompt:

```text
/help              Show help
/add file.sh       Add file to context
/drop file.sh      Remove file from context
/ls                List files in context
/diff              Show pending changes
/undo              Undo last change
/commit            Commit changes
/quit              Exit Aider
```

## Quick Examples

### Create New Script

```bash
aider AGENTS.md commons.sh

> Create a new script 'test-connection.sh' that:
> 1. Follows AGENTS.md standards
> 2. Uses commons.sh for logging
> 3. Tests Aruba switch connectivity
> 4. Validates all dependencies
```

### Fix Issues

```bash
aider aruba-auth.sh

> Fix authentication timeout issues and add retry logic
> with exponential backoff
```

### Add Tests

```bash
aider create-vrf.sh tests/test_create-vrf.bats

> Add comprehensive BATS tests for all functions
> following the pattern in test_helper.bash
```

## Environment Variables (pre-configurado no Dev Container)

- `OPENAI_API_BASE=https://api.githubcopilot.com`
- `OPENAI_API_KEY=${GITHUB_TOKEN}`
- `AIDER_MODEL=gpt-4`

## Validate Setup

```bash
./validate-aider.sh  # ou ./ai-support/scripts/validate-aider.sh
```

## Full Documentation

See [`AIDER_SETUP.md`](AIDER_SETUP.md) for complete guide.

## Troubleshooting

**Auth failed?**

```bash
export OPENAI_API_KEY=$(gh auth token)
```

**Aider not found?**

```bash
pip3 install aider-install
```

**Need help?**

```bash
aider --help
cat ./ai-support/docs/AIDER_SETUP.md
```
