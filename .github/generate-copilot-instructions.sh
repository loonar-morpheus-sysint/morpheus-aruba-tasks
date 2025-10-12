#!/bin/bash
################################################################################
# Script: generate-copilot-instructions.sh
# Description: Gera instruções do Copilot a partir do AGENTS.md
################################################################################
#
# DESCRIÇÃO:
#   Extrai conteúdo relevante do AGENTS.md e gera o arquivo JSON
#   copilot-codegen-instructions.json com instruções para o GitHub Copilot
#
# DEPENDÊNCIAS:
#   - jq: Para manipulação de JSON
#
# SAÍDA:
#   - copilot-codegen-instructions.json: Arquivo JSON com instruções
#
################################################################################

# Verifica se o arquivo AGENTS.md existe
if [ ! -f "AGENTS.md" ]; then
  echo "❌ Erro: AGENTS.md não encontrado."
  exit 1
fi

# Verifica dependência jq
if ! command -v jq &> /dev/null; then
  echo "❌ Erro: jq não encontrado. Instale com: sudo apt-get install jq"
  exit 1
fi

echo "📝 Extraindo instruções do AGENTS.md..."

# Extrai seções principais do documento
extract_section() {
  local section="$1"
  local content
  content=$(awk "/$section/,/^## / {print}" AGENTS.md | grep -v "^## " | sed '/^$/d')
  echo "$content"
}

# Monta o conteúdo completo das instruções
instructions=$(cat <<'EOF'
# Morpheus Aruba Tasks - Coding Guidelines

## Purpose
Guide AI and human code agents in creating Bash scripts for Aruba network automations integrated with Morpheus, following established standards for centralized logging, consistent naming, and development best practices.

## Architecture
- All scripts MUST use commons.sh library for standardized logging (all syslog levels), common utility functions, environment variable validation, and consistent error handling.

## Mandatory Header Template
All scripts MUST follow this EXACT header format:
```bash
#!/bin/bash
################################################################################
# Script: script-name.sh
# Description: Brief description of what the script does
################################################################################
# Detailed description (optional)
################################################################################
source "$(dirname "${BASH_SOURCE[0]}")/commons.sh"
```
CRITICAL: Lines `# Script:` and `# Description:` must be present in this EXACT format. BATS tests validate this pattern.

## Naming Conventions
- Files: MANDATORY use hyphens (-) to separate words. Pattern: verb-noun.sh (e.g., create-vrf.sh, install-aruba-cli.sh)
- Functions: Pattern: verb_noun() with underscore (e.g., validate_config(), aruba_check_auth())
- Variables: GLOBALS in UPPERCASE_WITH_UNDERSCORE, locals in lowercase_with_underscore
- MANDATORY: Always use Portuguese variable names prioritizing readability over conciseness (e.g., arquivo_configuracao, CAMINHO_BACKUP)

## Logging Standards
CRITICAL RULE: ALL functions MUST have entry and exit logging. This is a mandatory BATS validation.
```bash
my_function() {
  _log_func_enter "my_function"  # MANDATORY: First line
  # function logic
  _log_func_exit_ok "my_function"  # MANDATORY: Before return 0
  return 0
}
```
IMPORTANT:
- _log_func_enter must be the FIRST line of every function
- _log_func_exit_ok must precede ALL return 0 statements
- _log_func_exit_fail must precede ALL return 1 statements (or other error codes)
- Function name must be EXACTLY the same in enter/exit calls

## Mandatory Script Structure
CRITICAL: Every executable script MUST have a main() function and sourcing protection:
```bash
main() {
  _log_func_enter "main"
  log_info "Starting processing..."
  # Your code here
  _log_func_exit_ok "main"
  return 0
}

# Execute main only if script is called directly (not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi
```

## Dependency Validation
MANDATORY: Always validate dependencies BEFORE using them:
```bash
if ! command -v python3 &> /dev/null; then
  log_error "python3 is required but not installed"
  exit 1
fi
```
NEVER assume a command exists. ALWAYS validate with `command -v`.

## AI Agent Guidelines - When Creating New Scripts
1. ALWAYS use the EXACT header template (Script: / Description:)
2. ALWAYS include commons.sh as first functional line
3. ALWAYS create main() function with sourcing protection
4. ALWAYS implement _log_func_enter and _log_func_exit_* logging in ALL functions
5. ALWAYS use hyphenated naming for files
6. ALWAYS validate dependencies with command -v before using
7. ALWAYS validate parameters and environment variables
8. ALWAYS use Portuguese variable names (prioritize readability over conciseness)

## Quality Checklist (BATS Validation)
CRITICAL: The following items are AUTOMATICALLY VALIDATED by BATS tests:

### Script Structure (MANDATORY)
- Header contains `# Script: script-name.sh` (exact format)
- Header contains `# Description: ...` (exact format)
- Correct shebang: `#!/bin/bash` or `#!/usr/bin/env bash`
- Script uses `source.*commons.sh`
- Filename follows kebab-case pattern (`name-with-hyphens.sh`)
- Script is executable (chmod +x)

### Functions (MANDATORY)
- main() function exists and is implemented
- ALL functions have _log_func_enter "function_name" as first line
- ALL functions have _log_func_exit_ok before return 0
- ALL functions have _log_func_exit_fail before return 1
- Script has protection: if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then main "$@"; fi

### Logging and Errors (MANDATORY)
- Script uses log functions: log_info, log_error, log_success, log_warning
- Script has error handling: return 1 or exit 1
- Script uses appropriate return codes

### Validations (MANDATORY)
- Validates required environment variables (e.g., ARUBA_HOST)
- Validates dependencies with command -v before using
- Validates mandatory parameters

### Documentation (MANDATORY)
- Descriptive comments in main sections
- Consistent use of log levels

TIP: Run ./run-tests.sh to automatically validate all these items.

## Code Validation
ALL Bash scripts (.sh) MUST be validated with shellcheck before submission:
```bash
shellcheck script-name.sh
```
ALL Markdown files (.md) MUST be validated with markdownlint:
```bash
markdownlint document.md
```

## Common Mistakes to Avoid
❌ DON'T:
- Header without standard format
- Functions without logging
- Loose code (without main)
- Using commands without validation
- Exit/Return without logging

✅ DO:
- Standardized header
- Complete function logging
- Code in main()
- Validate before using
- Exit/Return with logging

## Standards Maintenance
- Always reference this document as base
- Maintain consistency with established patterns
- Apply all guidelines without exception
- Prioritize readability and maintainability
EOF
)

echo "✅ Conteúdo extraído com sucesso!"
echo "📄 Gerando JSON..."

# Captura a data atual
current_date=$(date -u +%Y-%m-%dT%H:%M:%SZ)

# Cria JSON com jq
if jq -n --arg text "$instructions" --arg date "$current_date" '{
  "version": "1.0",
  "generated": $date,
  "source": "AGENTS.md",
  "instructions": $text
}' > copilot-codegen-instructions.json; then
  echo "✅ Arquivo copilot-codegen-instructions.json criado com sucesso!"
  echo "📊 Estatísticas:"
  echo "   - Tamanho: $(wc -c < copilot-codegen-instructions.json) bytes"
  echo "   - Linhas: $(wc -l < copilot-codegen-instructions.json)"
else
  echo "❌ Erro ao criar o arquivo JSON"
  exit 1
fi
