# Development Tools Directory

Utility scripts for project development, maintenance, and automation.

## Migration Tools

- **migrate-bash-layout.sh** - Migrates project structure to standardized layout
- **migrate-simple.sh** - Simplified migration script

## Documentation Tools

- **generate-copilot-instructions.sh** - Generates Copilot instructions from AGENTS.md
- **watch-agents.sh** - Monitors AGENTS.md changes and regenerates instructions

## DevContainer Tools

- **copilot-sync-devcontainer.sh** - Syncs devcontainer.json with documentation
- **update-devcontainer-sync.sh** - Guides user to sync devcontainer files

## Test Utilities

- **move-test-scripts.sh** - Organizes manual test scripts

## Usage

These scripts are for project maintenance and should be run from the repository root:

```bash
# Generate Copilot instructions
./tools/generate-copilot-instructions.sh

# Watch for AGENTS.md changes
./tools/watch-agents.sh

# Sync devcontainer documentation
./tools/copilot-sync-devcontainer.sh
```

## Note

These tools use the central library when applicable: `../lib/commons.sh`
