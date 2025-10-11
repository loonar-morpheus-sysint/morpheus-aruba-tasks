# AGENTS.md

*Guia para Agentes de Código (AI e Humanos) - Automações Aruba/Morpheus*

## Propósito

Este documento orienta agentes de código (inteligência artificial e desenvolvedores humanos) na criação de scripts Bash para automações de redes Aruba integradas ao Morpheus, seguindo padrões estabelecidos de logging centralizado, nomenclatura consistente e boas práticas de desenvolvimento.

**Referência**: Este documento segue os padrões da iniciativa [agents.md](https://agents.md) para documentação direcionada a agentes autônomos.

## Arquitetura e Dependências

### commons.sh - Biblioteca Central

Todos os scripts devem utilizar o arquivo `commons.sh` como base para:

- Sistema de logging padronizado (todos os níveis syslog)
- Funções utilitárias comuns
- Validação de variáveis de ambiente
- Tratamento de erros consistente

### Exemplo de Inclusão:

```bash
#!/bin/bash
# Script: exemplo-aruba.sh
# Descrição: Script exemplo seguindo padrões estabelecidos

# Carrega biblioteca comum (deve ser a primeira linha após o shebang e comentários)
source "$(dirname "${BASH_SOURCE[0]}")/commons.sh"

# Resto do script...
```

## Convenções de Nomenclatura

### Arquivos

- **OBRIGATÓRIO**: Use hífens (`-`) para separar palavras
- **PADRÃO**: `verbo-substantivo.sh`
- **Exemplos**: `create-vrf.sh`, `install-aruba-cli.sh`, `backup-config.sh`

### Funções

- **PADRÃO**: `verbo_substantivo()` (underscore)
- **Prefixo**: Use prefixo quando necessário (`aruba_authenticate`, `morpheus_deploy`)
- **Exemplos**: `validate_config()`, `aruba_check_auth()`, `create_backup()`

### Variáveis

- **GLOBAIS**: `MAIÚSCULAS_COM_UNDERSCORE`
- **Locais**: `minúsculas_com_underscore`
- **Exemplos**: `ARUBA_HOST`, `CONFIG_PATH`, `backup_file`

## Padrão de Logging

### Logging Obrigatório em Funções

Todas as funções devem implementar logging de entrada, saída e erros:

```bash
minha_funcao() {
  _log_func_enter "minha_funcao"  # Entrada da função
  
  log_info "Executando operação X"  # Operações importantes
  
  log_info "Coletando informações do sistema"
  
  if aoscx "show version" > "system_info.txt"; then
    log_success "Informações coletadas em system_info.txt"
    _log_func_exit_ok "collect_system_info"
    return 0
  else
    log_error "Falha na coleta de informações"
    _log_func_exit_fail "collect_system_info" "1"
    return 1
  fi
}
```

## Diretrizes para Agentes AI

### Quando Criar Novos Scripts

1. **SEMPRE** use o template base fornecido
2. **SEMPRE** inclua `commons.sh` como primeira linha funcional
3. **SEMPRE** implemente logging completo em todas as funções
4. **SEMPRE** use nomenclatura com hífens para arquivos
5. **SEMPRE** valide parâmetros e variáveis de ambiente

### Checklist de Qualidade

- [ ] Script usa `commons.sh`
- [ ] Nome do arquivo com hífens
- [ ] Todas as funções têm `_log_func_enter` e `_log_func_exit_*`
- [ ] Tratamento adequado de códigos de retorno
- [ ] Comentários descritivos em seções principais
- [ ] Validação de parâmetros obrigatórios
- [ ] Uso consistente dos níveis de log
- [ ] Função `main()` implementada
- [ ] Proteção contra execução acidental quando sourced

## Validação de Código e Documentação

### Validação Obrigatória de Scripts Shell

**TODOS** os scripts Bash (`.sh`) devem ser validados com **shellcheck** antes de serem submetidos ao repositório. Esta é uma prática obrigatória que garante:

- Detecção de erros sintáticos e semânticos
- Identificação de más práticas e armadilhas comuns
- Conformidade com padrões POSIX quando aplicável
- Código mais robusto e manutenível

#### Como Validar Scripts com shellcheck

**Instalação:**

```bash
# Ubuntu/Debian
sudo apt-get install shellcheck

# macOS
brew install shellcheck

# Fedora
sudo dnf install shellcheck
```

**Exemplo de uso:**

```bash
# Validar um único script
shellcheck meu-script.sh

# Validar todos os scripts do diretório
shellcheck *.sh

# Validar com severidade específica (error, warning, info, style)
shellcheck -S warning meu-script.sh
```

**Exemplo de saída esperada:**

```bash
$ shellcheck create-vrf.sh

In create-vrf.sh line 42:
  if [ $? -eq 0 ]; then
       ^-- SC2181: Check exit code directly with e.g. 'if mycmd;', not indirectly with $?.
```

**IMPORTANTE**: Corrija todos os avisos e erros reportados pelo shellcheck antes de fazer commit. Scripts com avisos críticos não devem ser aceitos no repositório.

### Validação Obrigatória de Arquivos Markdown

**TODOS** os arquivos Markdown (`.md`) devem ser validados com **markdownlint** para assegurar padronização, legibilidade e consistência na documentação. Esta é uma prática obrigatória que garante:

- Formatação consistente em toda a documentação
- Legibilidade melhorada
- Conformidade com padrões de estilo estabelecidos
- Documentação profissional e de fácil manutenção

#### Como Validar Markdown com markdownlint

**Instalação:**

```bash
# Via npm (Node.js necessário)
npm install -g markdownlint-cli

# Via yarn
yarn global add markdownlint-cli
```

**Exemplo de uso:**

```bash
# Validar um arquivo específico
markdownlint README.md

# Validar todos os arquivos Markdown
markdownlint *.md

# Validar e corrigir automaticamente problemas simples
markdownlint --fix AGENTS.md

# Validar com configuração personalizada
markdownlint -c .markdownlint.json *.md
```

**Exemplo de saída esperada:**

```bash
$ markdownlint AGENTS.md

AGENTS.md:15 MD022/blanks-around-headings Headings should be surrounded by blank lines
AGENTS.md:23 MD031/blanks-around-fences Fenced code blocks should be surrounded by blank lines
```

**IMPORTANTE**: Corrija todos os avisos reportados pelo markdownlint antes de fazer commit. A documentação deve seguir padrões consistentes em todo o projeto.

### Integração no Workflow de Desenvolvimento

#### Antes de Fazer Commit

**Para Scripts Bash:**

```bash
# 1. Execute shellcheck
shellcheck seu-script.sh

# 2. Corrija todos os problemas reportados
# 3. Execute novamente até não haver avisos
# 4. Faça o commit
git add seu-script.sh
git commit -m "Add: Novo script validado com shellcheck"
```

**Para Arquivos Markdown:**

```bash
# 1. Execute markdownlint
markdownlint seu-documento.md

# 2. Corrija os problemas ou use --fix para correções automáticas
markdownlint --fix seu-documento.md

# 3. Revise as mudanças
# 4. Faça o commit
git add seu-documento.md
git commit -m "Docs: Atualização validada com markdownlint"
```

#### Automação com Git Hooks (Recomendado)

Considere criar um `.git/hooks/pre-commit` para validação automática:

```bash
#!/bin/bash
# .git/hooks/pre-commit

echo "Executando validações..."

# Valida scripts modificados
for file in $(git diff --cached --name-only --diff-filter=ACM | grep '\.sh$'); do
  echo "Validando $file com shellcheck..."
  shellcheck "$file" || exit 1
done

# Valida arquivos Markdown modificados
for file in $(git diff --cached --name-only --diff-filter=ACM | grep '\.md$'); do
  echo "Validando $file com markdownlint..."
  markdownlint "$file" || exit 1
done

echo "✓ Todas as validações passaram!"
exit 0
```

### Resumo das Boas Práticas de Validação

✅ **OBRIGATÓRIO**: Validar todos os scripts `.sh` com shellcheck
✅ **OBRIGATÓRIO**: Validar todos os arquivos `.md` com markdownlint
✅ **RECOMENDADO**: Usar git hooks para automação
✅ **RECOMENDADO**: Integrar validações no CI/CD pipeline
✅ **BOA PRÁTICA**: Corrigir todos os avisos, não apenas erros
✅ **BOA PRÁTICA**: Executar validações localmente antes do push

## Manutenção de Padrões

### Para Agentes Humanos

- Revisar este documento antes de criar novos scripts
- Usar scripts existentes como referência
- Contribuir com melhorias neste guia

### Para Agentes AI

- Sempre referenciar este documento como base
- Manter consistência com padrões estabelecidos
- Aplicar todas as diretrizes sem exceção
- Priorizar legibilidade e manutenibilidade

---

**Nota**: Este documento deve ser atualizado conforme novos padrões são estabelecidos no projeto. Mantenha sempre a versão mais recente como referência.
