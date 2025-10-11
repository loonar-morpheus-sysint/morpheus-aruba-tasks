# Changelog - DevContainer Configuration

## [2.0.0] - 2025-10-11

### 🚀 Principais Melhorias

#### Python Ecosystem

- ⬆️ **Atualizado para Python 3.12** (última versão estável)
- ✨ Adicionado suporte completo a `venv`
- 📦 Instaladas ferramentas de qualidade de código:
  - `pylint` - Análise estática
  - `flake8` - Verificação de estilo
  - `black` - Formatador de código
  - `autopep8` - Formatador PEP8
  - `mypy` - Verificação de tipos
  - `bandit` - Análise de segurança
  - `safety` - Verificação de vulnerabilidades
  - `pytest` e `pytest-cov` - Testes e cobertura
  - `ipython` - Shell interativo avançado
  - `ansible` e `ansible-lint` - Automação de infraestrutura

#### Node.js Ecosystem

- ⬆️ **Atualizado para Node.js 20.x LTS** (última versão LTS)
- ⬆️ npm atualizado para a última versão
- 📦 Instaladas ferramentas globais:
  - `markdownlint-cli` e `markdownlint-cli2`
  - `prettier` - Formatador multi-linguagem
  - `eslint` - Linter JavaScript/TypeScript
  - `typescript` - Suporte TypeScript
  - `bash-language-server` - Language server para Bash

#### Bash Development Tools

- ✨ Adicionado `shfmt` - Formatador de scripts Shell
- ✨ Adicionado `bash-language-server` - Suporte IDE para Bash
- 📦 Ferramentas básicas já presentes:
  - `shellcheck` - Análise estática
  - `yamllint` - Validação YAML

#### VS Code Extensions

##### Novas Extensões Bash

- `mads-hartmann.bash-ide-vscode` - IDE features para Bash

##### Novas Extensões Python

- `ms-python.python` - Suporte Python completo
- `ms-python.vscode-pylance` - Language server Python
- `ms-python.pylint` - Integração pylint
- `ms-python.flake8` - Integração flake8
- `ms-python.black-formatter` - Integração black
- `ms-python.debugpy` - Debugger Python

##### Novas Extensões Markdown

- `yzhang.markdown-all-in-one` - Ferramentas Markdown completas
- `bierner.markdown-preview-github-styles` - Preview estilo GitHub

##### Novas Extensões Git

- `github.vscode-pull-request-github` - Gerenciamento de PRs
- `eamodio.gitlens` - Recursos avançados Git
- `donjayamanne.githistory` - Histórico Git

##### Novas Extensões Qualidade

- `editorconfig.editorconfig` - Suporte EditorConfig
- `esbenp.prettier-vscode` - Integração Prettier
- `usernamehw.errorlens` - Erros inline
- `aaron-bond.better-comments` - Comentários aprimorados
- `streetsidesoftware.code-spell-checker` - Verificador ortográfico
- `wayou.vscode-todo-highlight` - Destaque TODOs
- `gruntfuggly.todo-tree` - Árvore de TODOs

##### Novas Extensões Segurança

- `snyk-security.snyk-vulnerability-scanner` - Scanner de vulnerabilidades

##### Novas Extensões DevOps

- `ms-azuretools.vscode-docker` - Suporte Docker
- `ms-vscode-remote.remote-containers` - Remote Containers

#### Configurações VS Code Aprimoradas

- ✨ Configuração completa para shellcheck
- ✨ Configuração completa para shell-format
- ✨ Configuração completa para Bash IDE
- ✨ Configuração completa para Python (linting, formatting, type checking)
- ✨ Configuração de formatadores padrão por tipo de arquivo
- ✨ Rulers em 80 e 120 caracteres
- ✨ Format on Save habilitado
- ✨ Fix All on Save habilitado
- ✨ Configurações de terminal aprimoradas

#### DevContainer Features

- ✨ Adicionado `docker-in-docker` - Suporte para containers dentro do DevContainer
- ⬆️ GitHub CLI e Git com versões latest
- ✨ Nova montagem: `~/.ssh` - Chaves SSH do host

#### Post-Create Script

- 🎨 Interface completamente reformulada com separadores visuais
- ✅ Verificação abrangente de todas as ferramentas instaladas
- 📊 Agrupamento lógico por categorias
- 🔧 Criação automática de diretórios úteis (`logs/`, `backups/`, `tmp/`, `configs/`)
- 📋 Informações detalhadas do ambiente
- 💡 Dicas de uso no final da execução
- 🐛 Código validado com shellcheck (apenas 1 aviso informativo SC2312)

#### Documentação

- 📚 Criado `.devcontainer/README.md` completo com:
  - Visão geral de todas as ferramentas instaladas
  - Guia de uso de cada ferramenta
  - Comandos úteis
  - Configurações personalizadas
  - Troubleshooting
  - Referências externas

### 🔧 Melhorias Técnicas

- 🏗️ Dockerfile otimizado com camadas separadas
- 📦 Instalação de dependências de build
- 🐍 Python 3.12 configurado como padrão via update-alternatives
- 📌 Versões fixadas em LTS quando disponível
- 🧹 Limpeza adequada de cache apt
- 👤 Configuração de usuário não-root mantida
- 🔒 Variáveis de ambiente adequadamente configuradas

### 📝 Arquivos Modificados

1. **Dockerfile**
   - Refatoração completa
   - Python 3.12 via PPA deadsnakes
   - Node.js 20.x LTS
   - Ferramentas adicionais de desenvolvimento
   - Aliases bash úteis

2. **devcontainer.json**
   - 20+ novas extensões VS Code
   - Configurações detalhadas por linguagem
   - Formatadores padrão configurados
   - Nova montagem SSH
   - Docker-in-Docker feature

3. **post-create.sh**
   - Refatoração completa
   - Interface visual aprimorada
   - Verificações abrangentes
   - Código seguindo boas práticas
   - Validado com shellcheck

4. **README.md** (novo)
   - Documentação completa do ambiente
   - Guias de uso
   - Referências
   - Troubleshooting

5. **CHANGELOG.md** (novo)
   - Histórico de mudanças
   - Documentação de versões

### 🎯 Conformidade

- ✅ Seguindo diretrizes do `AGENTS.md`
- ✅ Scripts validados com `shellcheck`
- ✅ Documentação validada com `markdownlint` (com avisos conhecidos de linha longa)
- ✅ Padrões de nomenclatura respeitados
- ✅ Logging adequado implementado

### 🔄 Como Atualizar

Para aplicar estas mudanças:

```bash
# 1. No VS Code, abra a paleta de comandos (F1)
# 2. Execute: Dev Containers: Rebuild Container
# 3. Aguarde a reconstrução completa
# 4. Verifique a saída do post-create.sh
```

### 📊 Estatísticas

- **Extensões VS Code**: 8 → 31 (+23)
- **Ferramentas Python**: 3 → 15 (+12)
- **Ferramentas Node.js**: 1 → 6 (+5)
- **Ferramentas Bash**: 1 → 4 (+3)
- **Features DevContainer**: 2 → 3 (+1)
- **Montagens**: 2 → 3 (+1)

### 🐛 Problemas Conhecidos

- ⚠️ `.devcontainer/README.md` tem avisos de linha longa do markdownlint (MD013)
- ℹ️ `post-create.sh` tem 1 aviso informativo SC2312 (não crítico)

### 📚 Referências

- [Python 3.12 Release Notes](https://docs.python.org/3.12/whatsnew/3.12.html)
- [Node.js 20 LTS](https://nodejs.org/en/blog/release/v20.0.0)
- [DevContainers Specification](https://containers.dev/)
- [Shellcheck Wiki](https://www.shellcheck.net/)

---

**Nota**: Esta atualização foi realizada seguindo as melhores práticas de desenvolvimento e as diretrizes estabelecidas no projeto.
