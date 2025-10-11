# DevContainer - Morpheus Aruba Tasks

## Visão Geral

Este DevContainer fornece um ambiente de desenvolvimento completo e consistente para o projeto Morpheus Aruba Tasks, com todas as ferramentas necessárias para desenvolvimento de scripts Bash, Python e documentação Markdown.

## 🛠️ Ferramentas Instaladas

### Core Development

- **Git** (latest) - Controle de versão
- **GitHub CLI** (latest) - Interação com GitHub via linha de comando
- **Docker-in-Docker** - Suporte para containers dentro do DevContainer

### Python Ecosystem (v3.12)

- **Python 3.12** - Última versão estável do Python
- **pip** - Gerenciador de pacotes Python (latest)
- **venv** - Ambiente virtual Python

#### Ferramentas de Qualidade Python

- **pylint** - Análise estática de código
- **flake8** - Verificação de estilo e erros
- **black** - Formatador de código
- **autopep8** - Formatador PEP8
- **mypy** - Verificação de tipos estáticos
- **bandit** - Análise de segurança
- **safety** - Verificação de vulnerabilidades em dependências
- **pytest** - Framework de testes
- **pytest-cov** - Cobertura de testes

#### Ferramentas Python Adicionais

- **ipython** - Shell interativo avançado
- **ansible** - Automação de infraestrutura
- **ansible-lint** - Validação de playbooks Ansible

### Node.js Ecosystem (v20 LTS)

- **Node.js 20.x** - Última versão LTS
- **npm** (latest) - Gerenciador de pacotes Node.js

#### Ferramentas Node.js

- **markdownlint-cli** - Validação de Markdown
- **markdownlint-cli2** - Versão melhorada do markdownlint
- **prettier** - Formatador de código multi-linguagem
- **eslint** - Linter JavaScript/TypeScript
- **typescript** - Suporte TypeScript
- **bash-language-server** - Language server para Bash

### Bash Development

- **shellcheck** - Análise estática de scripts Bash
- **shfmt** - Formatador de scripts Shell
- **yamllint** - Validação de arquivos YAML

### Security & Quality

- **pre-commit** - Framework de hooks Git
- **detect-secrets** - Detecção de secrets em código

## 📦 Extensões VS Code

### Desenvolvimento Bash

- `timonwong.shellcheck` - Integração shellcheck
- `rogalmic.bash-debug` - Debugger para Bash
- `foxundermoon.shell-format` - Formatação de scripts
- `mads-hartmann.bash-ide-vscode` - IDE features para Bash

### Desenvolvimento Python

- `ms-python.python` - Suporte Python completo
- `ms-python.vscode-pylance` - Language server Python
- `ms-python.pylint` - Integração pylint
- `ms-python.flake8` - Integração flake8
- `ms-python.black-formatter` - Integração black
- `ms-python.debugpy` - Debugger Python

### Markdown & Documentação

- `davidanson.vscode-markdownlint` - Validação Markdown
- `yzhang.markdown-all-in-one` - Ferramentas Markdown
- `bierner.markdown-preview-github-styles` - Preview estilo GitHub

### Git & GitHub

- `github.vscode-pull-request-github` - Gerenciamento de PRs
- `github.vscode-github-actions` - Integração GitHub Actions
- `eamodio.gitlens` - Recursos avançados Git
- `donjayamanne.githistory` - Histórico Git

### AI & Produtividade

- `github.copilot` - GitHub Copilot
- `github.copilot-chat` - Chat com Copilot

### Qualidade de Código

- `editorconfig.editorconfig` - Suporte EditorConfig
- `esbenp.prettier-vscode` - Integração Prettier
- `usernamehw.errorlens` - Erros inline
- `aaron-bond.better-comments` - Comentários aprimorados
- `streetsidesoftware.code-spell-checker` - Verificador ortográfico
- `wayou.vscode-todo-highlight` - Destaque TODOs
- `gruntfuggly.todo-tree` - Árvore de TODOs

### Segurança

- `snyk-security.snyk-vulnerability-scanner` - Scanner de vulnerabilidades

### Container & DevOps

- `ms-azuretools.vscode-docker` - Suporte Docker
- `ms-vscode-remote.remote-containers` - Remote Containers

## 🚀 Como Usar

### Iniciar o DevContainer

1. Abra o projeto no VS Code
2. Pressione `F1` e selecione `Dev Containers: Reopen in Container`
3. Aguarde a construção e configuração do container
4. O script `post-create.sh` será executado automaticamente

### Comandos Úteis

#### Validação de Scripts Bash

```bash
# Validar um script específico
shellcheck meu-script.sh

# Validar todos os scripts
shellcheck *.sh

# Formatar um script
shfmt -i 2 -ci -bn -w meu-script.sh
```

#### Validação de Markdown

```bash
# Validar um arquivo
markdownlint README.md

# Validar todos os arquivos Markdown
markdownlint *.md

# Corrigir automaticamente problemas
markdownlint --fix *.md
```

#### Python

```bash
# Verificar código com pylint
pylint meu_script.py

# Verificar estilo com flake8
flake8 meu_script.py

# Formatar com black
black meu_script.py

# Verificar tipos com mypy
mypy meu_script.py

# Executar testes
pytest

# Verificar segurança
bandit -r .
```

#### Pre-commit

```bash
# Executar todos os hooks
pre-commit run --all-files

# Executar hook específico
pre-commit run shellcheck --all-files

# Atualizar hooks
pre-commit autoupdate
```

#### GitHub CLI

```bash
# Ver status do repositório
gh repo view

# Criar issue
gh issue create

# Criar pull request
gh pr create

# Ver PRs abertos
gh pr list
```

## 📝 Configurações Personalizadas

### Editor

- **EOL**: LF (Unix)
- **Insert Final Newline**: true
- **Trim Trailing Whitespace**: true
- **Format On Save**: true
- **Tab Size**: 2 (Bash/Shell), 4 (Python)

### Shellcheck

- Execução: On Type
- Path: `/usr/bin/shellcheck`

### Shell Format

- Path: `/usr/bin/shfmt`
- Flags: `-i 2 -ci -bn`

### Python

- Interpreter: `/usr/bin/python3`
- Linting: pylint, flake8
- Formatting: black

## 🔄 Montagens

O DevContainer monta automaticamente:

- `~/.gitconfig` - Configuração Git do host
- `~/.config/gh` - Configuração GitHub CLI do host
- `~/.ssh` - Chaves SSH do host (para autenticação Git)

## 📂 Estrutura de Diretórios

Após a criação do container, os seguintes diretórios são criados:

- `logs/` - Logs de execução
- `backups/` - Backups de configurações
- `tmp/` - Arquivos temporários
- `configs/` - Arquivos de configuração

## 🐛 Troubleshooting

### Container não inicia

1. Reconstrua o container: `F1` → `Dev Containers: Rebuild Container`
2. Verifique logs do Docker
3. Verifique espaço em disco

### Ferramentas não encontradas

Execute manualmente o script de pós-criação:

```bash
bash .devcontainer/post-create.sh
```

### Problemas com Git/GitHub

Verifique se as montagens estão corretas:

```bash
ls -la ~/.gitconfig
ls -la ~/.config/gh
ls -la ~/.ssh
```

## 📚 Referências

- [DevContainers Documentation](https://containers.dev/)
- [VS Code Remote Development](https://code.visualstudio.com/docs/remote/containers)
- [shellcheck Wiki](https://github.com/koalaman/shellcheck/wiki)
- [markdownlint Rules](https://github.com/DavidAnson/markdownlint/blob/main/doc/Rules.md)
- [pre-commit Documentation](https://pre-commit.com/)

## 🔄 Atualizações

Para atualizar ferramentas:

1. Edite `Dockerfile` ou `devcontainer.json`
2. Reconstrua o container
3. Teste as mudanças
4. Commite as alterações

---

**Nota**: Este ambiente é configurado seguindo as diretrizes do arquivo `AGENTS.md` do projeto.
