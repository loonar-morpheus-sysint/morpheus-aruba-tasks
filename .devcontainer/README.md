# DevContainer - Morpheus Aruba Tasks

## Visão Geral

Este DevContainer fornece um ambiente de desenvolvimento completo e consistente para o projeto Morpheus Aruba Tasks, com todas as ferramentas necessárias para desenvolvimento de scripts Bash, Python e documentação Markdown.

## 🛠️ Ferramentas Instaladas

### DevContainer Features

Conforme documentado em `../THIRDPARTY.md`, as seguintes features são instaladas automaticamente:

- **GitHub CLI (gh)** - `ghcr.io/devcontainers/features/github-cli:1` (latest)
- **Git com PPA** - `ghcr.io/devcontainers/features/git:1` (latest, sempre atualizado)
- **Docker-in-Docker** - `ghcr.io/devcontainers/features/docker-in-docker:2` (latest)
- **Python 3.11** - `ghcr.io/devcontainers/features/python:1` (versão 3.11 com ferramentas)

### Core Development

- **Git** (latest via PPA) - Controle de versão
- **GitHub CLI** (latest via feature) - Interação com GitHub via linha de comando
- **Docker** - Suporte para containers dentro do DevContainer (Docker-in-Docker)
- **curl**, **wget** - Download de arquivos
- **jq** - Processador JSON de linha de comando
- **vim**, **nano** - Editores de texto

### Python Ecosystem (v3.11+)

- **Python 3.11** - Última versão estável do Python
- **pip** - Gerenciador de pacotes Python (latest)
- **venv** - Ambiente virtual Python
- **pipx** - Gerenciador de aplicações Python isoladas

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
- **bats** - Framework de testes para Bash
- **yamllint** - Validação de arquivos YAML
- **inotify-tools** - Monitoramento de arquivos (para watch-agents.sh)
- **bash-language-server** - Language server para Bash (via npm)

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

#### Python (verification)

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

### Python (configuration)

- Interpreter: `/usr/bin/python3`
- Linting: pylint, flake8
- Formatting: black

## 🔄 Montagens

O DevContainer monta automaticamente os seguintes diretórios do host para compartilhar configurações e autenticações:

### Configurações Compartilhadas

| Origem (Host/WSL) | Destino (Container) | Descrição | Modo |
|-------------------|---------------------|-----------|------|
| `~/.config/gh` | `/home/vscode/.config/gh` | Autenticação GitHub CLI | Leitura/Escrita |
| `~/.gitconfig` | `/home/vscode/.gitconfig` | Configuração Git global | Leitura/Escrita |
| `~/.ssh` | `/home/vscode/.ssh` | Chaves SSH | Somente Leitura |

### Benefícios

- **GitHub CLI**: Use `gh` no container com a mesma autenticação da WSL/host
- **Git**: Commits usam seu nome e email configurados no host
- **SSH**: Acesse repositórios privados com suas chaves SSH existentes

### Como Funciona

Os mounts usam variáveis de ambiente que funcionam tanto em Linux/WSL quanto Windows:

```jsonc
"mounts": [
  // ${localEnv:HOME} para Linux/macOS/WSL
  // ${localEnv:USERPROFILE} para Windows
  "source=${localEnv:HOME}${localEnv:USERPROFILE}/.config/gh,target=/home/vscode/.config/gh,type=bind"
]
```

### Validar Compartilhamento

Após abrir o DevContainer, execute:

```bash
# Verificar GitHub CLI
gh auth status
# Deve mostrar sua autenticação da WSL/host

# Verificar Git
git config --global user.name
git config --global user.email
# Deve mostrar suas configurações do host

# Verificar chaves SSH
ls -la ~/.ssh/
# Deve listar suas chaves do host
```

### Troubleshooting: Autenticação não Compartilhada

**Problema**: `gh auth status` retorna erro ou pede autenticação

**Possíveis causas**:

1. **Diretório não existe no host**: Certifique-se que `~/.config/gh` existe na WSL

   ```bash
   # Na WSL, verificar:
   ls -la ~/.config/gh
   ```

2. **Permissões incorretas**: Rebuild o container

   ```text
   Dev Containers: Rebuild Container
   ```

3. **Caminho diferente no Windows**: O mount usa tanto `$HOME` (Linux/WSL) quanto `$USERPROFILE` (Windows)

**Solução alternativa - Autenticar manualmente no container**:

```bash
# Dentro do DevContainer
gh auth login
# Escolha: GitHub.com > HTTPS > Login via navegador
```

## 🔄 Montagens (Legado)

## 📂 Estrutura de Diretórios

Após a criação do container, os seguintes diretórios são criados:

- `logs/` - Logs de execução
- `backups/` - Backups de configurações
- `tmp/` - Arquivos temporários
- `configs/` - Arquivos de configuração

## 🐛 Troubleshooting

### GitHub CLI não encontrado após rebuild

**Problema**: `❌ GitHub CLI não encontrado` mesmo após rebuild

**Solução**:

1. Verifique se as features estão no `devcontainer.json`:

   ```jsonc
   "features": {
     "ghcr.io/devcontainers/features/github-cli:1": {
       "version": "latest"
     }
   }
   ```

2. Reconstrua sem cache: `F1` → `Dev Containers: Rebuild Container Without Cache`

3. Verifique a instalação manualmente no container:

   ```bash
   which gh
   gh --version
   ```

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
