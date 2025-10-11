# Guia de Contribuição

Obrigado por considerar contribuir para o projeto **Morpheus Aruba Tasks**! Este documento fornece diretrizes e padrões para garantir contribuições de qualidade e consistentes.

## 📋 Índice

- [Código de Conduta](#código-de-conduta)
- [Como Começar](#como-começar)
- [Ambiente de Desenvolvimento](#ambiente-de-desenvolvimento)
- [Padrões de Código](#padrões-de-código)
- [Processo de Contribuição](#processo-de-contribuição)
- [Validação e Testes](#validação-e-testes)
- [Convenções de Commit](#convenções-de-commit)
- [Revisão de Código](#revisão-de-código)

## 📜 Código de Conduta

Este projeto adere a padrões de conduta profissional. Ao participar, você concorda em:

- Ser respeitoso e inclusivo
- Aceitar críticas construtivas
- Focar no que é melhor para a comunidade
- Demonstrar empatia com outros membros

## 🚀 Como Começar

### Pré-requisitos

- Git instalado
- Docker instalado (para DevContainer)
- VS Code com extensão Remote Containers (recomendado)
- Conta GitHub configurada

### Fork e Clone

1. **Fork** este repositório no GitHub
2. **Clone** seu fork localmente:

```bash
git clone https://github.com/SEU-USUARIO/morpheus-aruba-tasks.git
cd morpheus-aruba-tasks
```

3. **Configure** o repositório upstream:

```bash
git remote add upstream https://github.com/loonar-morpheus-sysint/morpheus-aruba-tasks.git
```

## 🛠️ Ambiente de Desenvolvimento

### Usando DevContainer (Recomendado)

O projeto inclui um DevContainer completo com todas as ferramentas necessárias:

1. Abra o projeto no VS Code
2. Pressione `F1` e selecione `Dev Containers: Reopen in Container`
3. Aguarde a construção do container
4. O ambiente estará pronto com todas as ferramentas instaladas

### Ferramentas Incluídas

O DevContainer inclui:

- **Python 3.12** com pip, venv, pylint, flake8, black, mypy, bandit, pytest
- **Node.js 20 LTS** com npm, markdownlint, prettier, eslint, typescript
- **Bash Tools**: shellcheck, shfmt, bash-language-server, yamllint
- **Git Tools**: git, GitHub CLI (gh)
- **Security**: pre-commit, detect-secrets, bandit, safety
- **VS Code Extensions**: 31+ extensões para desenvolvimento

Consulte [`.devcontainer/README.md`](.devcontainer/README.md) para detalhes completos.

### Configuração Manual (Sem DevContainer)

Se preferir não usar DevContainer, instale manualmente:

```bash
# Ubuntu/Debian
sudo apt-get update
sudo apt-get install -y shellcheck shfmt git curl jq yamllint python3 python3-pip nodejs npm

# Ferramentas Python
pip3 install --user pre-commit pylint flake8 black mypy bandit pytest

# Ferramentas Node.js
npm install -g markdownlint-cli prettier eslint
```

## 📝 Padrões de Código

### Convenções de Nomenclatura

#### Arquivos Shell Script

- **Formato**: `verbo-substantivo.sh`
- **Separador**: hífens (`-`)
- **Exemplos**:
  - ✅ `create-vrf.sh`
  - ✅ `install-aruba-cli.sh`
  - ✅ `backup-config.sh`
  - ❌ `createVRF.sh`
  - ❌ `create_vrf.sh`

#### Funções

- **Formato**: `verbo_substantivo()`
- **Separador**: underscore (`_`)
- **Prefixo**: Use quando necessário (`aruba_`, `morpheus_`)
- **Exemplos**:

  ```bash
  validate_config()
  aruba_check_auth()
  create_backup()
  ```

#### Variáveis

- **Globais**: `MAIÚSCULAS_COM_UNDERSCORE`
- **Locais**: `minúsculas_com_underscore`
- **Exemplos**:

  ```bash
  ARUBA_HOST="switch.example.com"
  CONFIG_PATH="/etc/aruba"
  backup_file="backup_$(date +%Y%m%d).tar.gz"
  ```

### Template de Script Bash

Todos os scripts Bash **DEVEM** seguir este template:

```bash
#!/bin/bash
# Script: nome-do-script.sh
# Descrição: Breve descrição do que o script faz
# Autor: Seu Nome
# Data: YYYY-MM-DD

# Carrega biblioteca comum (OBRIGATÓRIO)
source "$(dirname "${BASH_SOURCE[0]}")/commons.sh"

# Variáveis globais
SCRIPT_NAME="nome-do-script"
VERSION="1.0.0"

# Funções
main_function() {
  _log_func_enter "main_function"
  
  log_info "Iniciando operação..."
  
  # Lógica do script aqui
  
  if comando_executado_com_sucesso; then
    log_success "Operação concluída"
    _log_func_exit_ok "main_function"
    return 0
  else
    log_error "Operação falhou"
    _log_func_exit_fail "main_function" "1"
    return 1
  fi
}

# Função principal
main() {
  _log_func_enter "main"
  
  main_function
  local exit_code=$?
  
  _log_func_exit_ok "main"
  return ${exit_code}
}

# Executa apenas se não estiver sendo sourced
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi
```

### Logging Obrigatório

Todas as funções **DEVEM** implementar logging:

```bash
minha_funcao() {
  _log_func_enter "minha_funcao"  # Entrada
  
  log_info "Executando ação X"    # Operações importantes
  log_debug "Detalhes técnicos"   # Debug (opcional)
  
  if operacao_sucesso; then
    log_success "Operação bem-sucedida"
    _log_func_exit_ok "minha_funcao"
    return 0
  else
    log_error "Operação falhou"
    _log_func_exit_fail "minha_funcao" "1"
    return 1
  fi
}
```

### Níveis de Log Disponíveis

Use conforme apropriado (definidos em `commons.sh`):

- `log_debug` - Informações detalhadas de debug
- `log_info` - Informações gerais
- `log_notice` - Eventos normais mas significativos
- `log_warning` - Avisos
- `log_error` - Erros
- `log_critical` - Erros críticos
- `log_alert` - Ação imediata requerida
- `log_emergency` - Sistema inutilizável
- `log_success` - Operação bem-sucedida

## 🔄 Processo de Contribuição

### 1. Crie uma Branch

```bash
# Atualize main
git checkout main
git pull upstream main

# Crie branch para sua feature
git checkout -b feature/nome-da-feature

# OU para bugfix
git checkout -b fix/nome-do-bug
```

### 2. Faça suas Alterações

- Siga os padrões de código
- Adicione logging adequado
- Documente mudanças significativas
- Atualize documentação se necessário

### 3. Valide suas Alterações

**OBRIGATÓRIO antes de commit:**

```bash
# Validar scripts Bash
shellcheck seu-script.sh

# Validar Markdown
markdownlint *.md

# Validar Python (se aplicável)
pylint seu_script.py
flake8 seu_script.py

# Executar pre-commit hooks
pre-commit run --all-files
```

### 4. Commit suas Alterações

Siga as [Convenções de Commit](#convenções-de-commit):

```bash
git add .
git commit -m "feat: adiciona nova funcionalidade X"
```

### 5. Push e Pull Request

```bash
# Push para seu fork
git push origin feature/nome-da-feature

# Crie Pull Request no GitHub
gh pr create --title "feat: Nova funcionalidade X" --body "Descrição detalhada"
```

## ✅ Validação e Testes

### Validação Obrigatória com shellcheck

**TODOS** os scripts `.sh` devem ser validados:

```bash
# Validar um script
shellcheck meu-script.sh

# Validar todos os scripts
shellcheck *.sh

# Corrigir todos os avisos reportados antes de commit
```

### Validação Obrigatória com markdownlint

**TODOS** os arquivos `.md` devem ser validados:

```bash
# Validar um arquivo
markdownlint README.md

# Validar todos
markdownlint *.md

# Corrigir automaticamente
markdownlint --fix *.md
```

### Validação Python (quando aplicável)

```bash
# Linting
pylint meu_script.py
flake8 meu_script.py

# Formatação
black meu_script.py

# Type checking
mypy meu_script.py

# Segurança
bandit -r .

# Testes
pytest
```

### Pre-commit Hooks

Configure hooks automáticos:

```bash
# Instalar hooks
pre-commit install
pre-commit install --hook-type commit-msg

# Executar manualmente
pre-commit run --all-files
```

## 📝 Convenções de Commit

Seguimos [Conventional Commits](https://www.conventionalcommits.org/). Veja [`COMMIT_CONVENTION.md`](COMMIT_CONVENTION.md) para detalhes completos.

### Formato

```
<tipo>(<escopo>): <descrição>

[corpo opcional]

[rodapé opcional]
```

### Tipos Principais

- `feat`: Nova funcionalidade
- `fix`: Correção de bug
- `docs`: Mudanças em documentação
- `style`: Formatação, ponto-e-vírgula, etc
- `refactor`: Refatoração de código
- `test`: Adição ou correção de testes
- `chore`: Tarefas de manutenção

### Exemplos

```bash
# Feature
git commit -m "feat(aruba): adiciona autenticação via SSH"

# Bugfix
git commit -m "fix(vrf): corrige validação de VLAN ID"

# Documentação
git commit -m "docs: atualiza README com novos exemplos"

# Breaking change
git commit -m "feat(api)!: muda formato de resposta da API

BREAKING CHANGE: O formato JSON agora retorna 'data' ao invés de 'result'"
```

## 👀 Revisão de Código

### Checklist para Reviewers

- [ ] Código segue padrões de nomenclatura
- [ ] Todos os scripts usam `commons.sh`
- [ ] Logging implementado em todas as funções
- [ ] Scripts validados com `shellcheck` (sem erros)
- [ ] Documentação validada com `markdownlint`
- [ ] Commits seguem Conventional Commits
- [ ] Testes passam (se aplicável)
- [ ] Documentação atualizada
- [ ] Sem secrets ou credenciais hardcoded
- [ ] Código é legível e bem comentado

### Processo de Review

1. **Automated Checks**: CI/CD executa validações automáticas
2. **Peer Review**: Pelo menos 1 aprovação necessária
3. **Discussion**: Discussões construtivas sobre melhorias
4. **Approval**: Aprovação final antes do merge

## 🐛 Reportando Bugs

Ao reportar bugs, inclua:

1. **Descrição clara** do problema
2. **Passos para reproduzir**:

   ```
   1. Execute comando X
   2. Configure Y
   3. Observe erro Z
   ```

3. **Comportamento esperado**
4. **Comportamento atual**
5. **Ambiente**:
   - OS e versão
   - Versão do Bash
   - Versões de dependências
6. **Logs relevantes**
7. **Screenshots** (se aplicável)

## 💡 Sugerindo Features

Para sugerir novas funcionalidades:

1. **Verifique** se já não existe issue similar
2. **Descreva** o problema que a feature resolve
3. **Proponha** solução detalhada
4. **Liste** alternativas consideradas
5. **Adicione** contexto adicional

## 📚 Recursos Adicionais

- [`AGENTS.md`](AGENTS.md) - Guia para agentes de código (AI e humanos)
- [`COMMIT_CONVENTION.md`](COMMIT_CONVENTION.md) - Convenções de commit detalhadas
- [`SETUP.md`](SETUP.md) - Guia de configuração do projeto
- [`SECURITY.md`](SECURITY.md) - Políticas de segurança
- [`.devcontainer/README.md`](.devcontainer/README.md) - Documentação do DevContainer

## 🙏 Agradecimentos

Suas contribuições tornam este projeto melhor! Agradecemos por:

- Reportar bugs
- Sugerir melhorias
- Submeter pull requests
- Revisar código
- Melhorar documentação

## 📞 Precisa de Ajuda?

- **Issues**: Abra uma issue no GitHub
- **Discussões**: Use GitHub Discussions
- **Pull Requests**: Crie um PR com suas dúvidas

---

**Última atualização**: 2025-10-11
**Versão**: 1.0.0

Obrigado por contribuir! 🚀
