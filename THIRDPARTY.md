# Tecnologias de Terceiros

Este documento lista todas as tecnologias, ferramentas, bibliotecas e serviços de terceiros
utilizados ou mencionados no projeto **Morpheus Aruba Tasks**.

## 📋 Índice

- Infraestrutura e Hardware
- Plataformas e Serviços
- Linguagens e Runtimes
- Ferramentas CLI Core
- Pacotes Python (pip)
- Pacotes Node.js (npm)
- Utilitários de Sistema
- Extensões VS Code
- DevContainer Features
- Padrões e Especificações
- Serviços Externos

---

## 🖥️ Infraestrutura e Hardware

| Nome | Versão | Descrição | Website | Licença |
|------|--------|-----------|---------|---------|
| HPE Aruba Networking | AOS-CX 10.13 | Solução de switching de rede da HPE | [Site](https://www.arubanetworks.com/) | Proprietário HPE |
| Aruba CLI | AOS-CX | Command Line Interface para switches Aruba | [Docs](https://www.arubanetworks.com/techdocs/AOS-CX/10.13/HTML/cli_reference/) | Proprietário HPE |
| Aruba REST API | AOS-CX | API REST para automação de switches | [Docs](https://www.arubanetworks.com/techdocs/AOS-CX/10.13/HTML/rest_api_guide/) | Proprietário HPE |

---

## 🌐 Plataformas e Serviços

| Nome | Versão | Descrição | Website | Licença |
|------|--------|-----------|---------|---------|
| Morpheus Data | - | Plataforma de orquestração e gerenciamento de nuvem híbrida | [Site](https://www.morpheusdata.com/) | Proprietário |
| GitHub | - | Plataforma de hospedagem de código e colaboração | [Site](https://github.com/) | Proprietário Microsoft |
| GitHub Actions | - | Plataforma de CI/CD integrada ao GitHub | [Site](https://github.com/features/actions) | Incluído no GitHub |
| Microsoft DevContainers | latest | Ambiente de desenvolvimento em container | [Site](https://containers.dev/) | MIT |

---

## 💻 Linguagens e Runtimes

| Nome | Versão | Fonte | Descrição | Website | Licença |
|------|--------|-------|-----------|---------|---------|
| Bash | 5.x+ | Ubuntu | Shell Unix e linguagem de script | [Site](https://www.gnu.org/software/bash/) | GPL-3.0 |
| Python | 3.12 | PPA deadsnakes | Linguagem de programação de alto nível | [Site](https://www.python.org/) | PSF License |
| Node.js | 20.x LTS | Nodesource | Runtime JavaScript baseado em V8 | [Site](https://nodejs.org/) | MIT |
| npm | latest | Node.js | Gerenciador de pacotes Node.js | [Site](https://www.npmjs.com/) | Artistic-2.0 |
| pip | latest | Python | Gerenciador de pacotes Python | [Site](https://pip.pypa.io/) | MIT |

---

## 🔧 Ferramentas CLI Core

| Nome | Versão | Instalação | Descrição | Website | Licença |
|------|--------|------------|-----------|---------|---------|
| git | latest (PPA) | apt | Sistema de controle de versão distribuído | [Site](https://git-scm.com/) | GPL-2.0 |
| gh | latest | Feature | GitHub CLI - Interface de linha de comando | [Site](https://cli.github.com/) | MIT |
| docker | latest | Feature | Plataforma de containerização | [Site](https://www.docker.com/) | Apache-2.0 |
| shellcheck | latest | apt | Analisador estático para scripts Shell | [Site](https://www.shellcheck.net/) | GPL-3.0 |
| shfmt | latest | apt | Formatador de scripts Shell | [GitHub](https://github.com/mvdan/sh) | BSD-3-Clause |
| yamllint | latest | apt | Validador e linter para YAML | [GitHub](https://github.com/adrienverge/yamllint) | GPL-3.0 |
| curl | latest | apt | Transferência de dados via URL | [Site](https://curl.se/) | MIT-like |
| wget | latest | apt | Download de arquivos | [Site](https://www.gnu.org/software/wget/) | GPL-3.0 |
| jq | latest | apt | Processador JSON de linha de comando | [Site](https://jqlang.github.io/jq/) | MIT |
| vim | latest | apt | Editor de texto | [Site](https://www.vim.org/) | Vim License |
| nano | latest | apt | Editor de texto simples | [Site](https://www.nano-editor.org/) | GPL-3.0 |

---

## 🐍 Pacotes Python (pip)

### Ferramentas de Desenvolvimento

| Nome | Versão | Descrição | Website | Licença |
|------|--------|-----------|---------|---------|
| setuptools | latest | Ferramentas de empacotamento Python | [PyPI](https://pypi.org/project/setuptools/) | MIT |
| wheel | latest | Formato de distribuição Python | [PyPI](https://pypi.org/project/wheel/) | MIT |
| ipython | latest | Shell interativo Python avançado | [Site](https://ipython.org/) | BSD-3-Clause |

### Linting e Análise de Código

| Nome | Versão | Descrição | Website | Licença |
|------|--------|-----------|---------|---------|
| pylint | latest | Analisador de código Python | [Site](https://pylint.org/) | GPL-2.0 |
| flake8 | latest | Verificador de estilo Python (PEP8) | [Site](https://flake8.pycqa.org/) | MIT |
| mypy | latest | Verificador de tipos estáticos para Python | [Site](https://mypy.readthedocs.io/) | MIT |

### Formatação (Python)

| Nome | Versão | Descrição | Website | Licença |
|------|--------|-----------|---------|---------|
| black | latest | Formatador de código Python | [Site](https://black.readthedocs.io/) | MIT |
| autopep8 | latest | Formatador automático PEP8 | [GitHub](https://github.com/hhatto/autopep8) | MIT |

### Segurança (Python)

| Nome | Versão | Descrição | Website | Licença |
|------|--------|-----------|---------|---------|
| bandit | latest | Ferramenta de segurança para Python | [Site](https://bandit.readthedocs.io/) | Apache-2.0 |
| safety | latest | Verificador de vulnerabilidades em dependências | [Site](https://safetycli.com/) | MIT |
| detect-secrets | latest | Detector de secrets em código | [GitHub](https://github.com/Yelp/detect-secrets) | Apache-2.0 |

### Testes

| Nome | Versão | Descrição | Website | Licença |
|------|--------|-----------|---------|---------|
| pytest | latest | Framework de testes Python | [Site](https://pytest.org/) | MIT |
| pytest-cov | latest | Plugin de cobertura para pytest | [GitHub](https://github.com/pytest-dev/pytest-cov) | MIT |

### Automação e CI/CD

| Nome | Versão | Descrição | Website | Licença |
|------|--------|-----------|---------|---------|
| pre-commit | latest | Framework de hooks Git | [Site](https://pre-commit.com/) | MIT |
| ansible | latest | Ferramenta de automação de infraestrutura | [Site](https://www.ansible.com/) | GPL-3.0 |
| ansible-lint | latest | Linter para Ansible playbooks | [Site](https://ansible.readthedocs.io/projects/lint/) | MIT |

---

## 📦 Pacotes Node.js (npm)

### Linting e Validação

| Nome | Versão | Descrição | Website | Licença |
|------|--------|-----------|---------|---------|
| markdownlint-cli | latest | Linter para arquivos Markdown | [GitHub](https://github.com/igorshubovych/markdownlint-cli) | MIT |
| markdownlint-cli2 | latest | Versão melhorada do markdownlint-cli | [GitHub](https://github.com/DavidAnson/markdownlint-cli2) | MIT |
| eslint | latest | Linter para JavaScript/TypeScript | [Site](https://eslint.org/) | MIT |

### Formatação (Node)

| Nome | Versão | Descrição | Website | Licença |
|------|--------|-----------|---------|---------|
| prettier | latest | Formatador de código opinativo | [Site](https://prettier.io/) | MIT |

### Desenvolvimento

| Nome | Versão | Descrição | Website | Licença |
|------|--------|-----------|---------|---------|
| typescript | latest | Superset tipado de JavaScript | [Site](https://www.typescriptlang.org/) | Apache-2.0 |
| bash-language-server | latest | Language server protocol para Bash | [GitHub](https://github.com/bash-lsp/bash-language-server) | MIT |

---

## 🔨 Utilitários de Sistema

### Ferramentas de Build

| Nome | Versão | Descrição | Licença |
|------|--------|-----------|---------|
| build-essential | latest | Meta-pacote com ferramentas de compilação (GCC, make, etc.) | Várias |
| software-properties-common | latest | Gerenciamento de repositórios e PPAs | GPL |

### Compactação e Arquivamento

| Nome | Versão | Descrição | Licença |
|------|--------|-----------|---------|
| zip | latest | Utilitário de compactação | BSD-like |
| unzip | latest | Utilitário de descompactação | BSD-like |

### Certificados e Criptografia

| Nome | Versão | Descrição | Licença |
|------|--------|-----------|---------|
| ca-certificates | latest | Certificados de autoridades certificadoras | MPL/GPL |
| gnupg | latest | GNU Privacy Guard - Criptografia e assinaturas | GPL-3.0 |
| lsb-release | latest | Informações de distribuição Linux | GPL |

---

## 🔌 Extensões VS Code

### Desenvolvimento Bash

| ID da Extensão | Nome | Descrição | Licença |
|----------------|------|-----------|---------|
| timonwong.shellcheck | ShellCheck | Integração shellcheck no VS Code | MIT |
| rogalmic.bash-debug | Bash Debug | Debugger para scripts Bash | MIT |
| foxundermoon.shell-format | Shell Format | Formatação de scripts Shell | MIT |
| mads-hartmann.bash-ide-vscode | Bash IDE | IDE features para Bash | MIT |

### Desenvolvimento Python

| ID da Extensão | Nome | Descrição | Licença |
|----------------|------|-----------|---------|
| ms-python.python | Python | Suporte Python completo | Proprietário Microsoft |
| ms-python.vscode-pylance | Pylance | Language server Python de alta performance | Proprietário Microsoft |
| ms-python.pylint | Pylint | Integração pylint | Proprietário Microsoft |
| ms-python.flake8 | Flake8 | Integração flake8 | Proprietário Microsoft |
| ms-python.black-formatter | Black Formatter | Integração black | Proprietário Microsoft |
| ms-python.debugpy | Python Debugger | Debugger Python | MIT |

### Markdown e Documentação

| ID da Extensão | Nome | Descrição | Licença |
|----------------|------|-----------|---------|
| davidanson.vscode-markdownlint | markdownlint | Validação de Markdown | MIT |
| yzhang.markdown-all-in-one | Markdown All in One | Ferramentas completas para Markdown | MIT |
| bierner.markdown-preview-github-styles | Markdown Preview GitHub Styles | Preview estilo GitHub | MIT |

### Git e GitHub

| ID da Extensão | Nome | Descrição | Licença |
|----------------|------|-----------|---------|
| github.vscode-pull-request-github | GitHub Pull Requests | Gerenciamento de PRs no VS Code | MIT |
| github.vscode-github-actions | GitHub Actions | Integração GitHub Actions | MIT |
| eamodio.gitlens | GitLens | Recursos avançados Git | MIT (com recursos premium) |
| donjayamanne.githistory | Git History | Visualização de histórico Git | MIT |

### AI Assistants

| ID da Extensão | Nome | Descrição | Licença |
|----------------|------|-----------|---------|
| github.copilot | GitHub Copilot | Assistente de código com IA | Proprietário GitHub/Microsoft |
| github.copilot-chat | GitHub Copilot Chat | Chat com IA para programação | Proprietário GitHub/Microsoft |

### Qualidade e Formatação

| ID da Extensão | Nome | Descrição | Licença |
|----------------|------|-----------|---------|
| editorconfig.editorconfig | EditorConfig | Suporte EditorConfig | MIT |
| esbenp.prettier-vscode | Prettier | Integração Prettier | MIT |
| redhat.vscode-yaml | YAML | Suporte para arquivos YAML | MIT |
| redhat.vscode-xml | XML | Suporte para arquivos XML | EPL-2.0 |

### Utilitários

| ID da Extensão | Nome | Descrição | Licença |
|----------------|------|-----------|---------|
| usernamehw.errorlens | Error Lens | Destaque de erros inline | MIT |
| aaron-bond.better-comments | Better Comments | Comentários aprimorados e categorizados | MIT |
| streetsidesoftware.code-spell-checker | Code Spell Checker | Verificador ortográfico | GPL-3.0 |
| wayou.vscode-todo-highlight | TODO Highlight | Destaque de TODOs e FIXMEs | MIT |
| gruntfuggly.todo-tree | TODO Tree | Visualização em árvore de TODOs | MIT |

### Segurança (Node)

| ID da Extensão | Nome | Descrição | Licença |
|----------------|------|-----------|---------|
| snyk-security.snyk-vulnerability-scanner | Snyk Security | Scanner de vulnerabilidades | Proprietário Snyk |

### Container e DevOps

| ID da Extensão | Nome | Descrição | Licença |
|----------------|------|-----------|---------|
| ms-azuretools.vscode-docker | Docker | Suporte Docker no VS Code | MIT |
| ms-vscode-remote.remote-containers | Remote Containers | Desenvolvimento em containers | Proprietário Microsoft |

---

## 🐳 DevContainer Features

| Feature | Versão | Descrição | Documentação | Licença |
|---------|--------|-----------|--------------|---------|
| ghcr.io/devcontainers/features/github-cli:1 | latest | GitHub CLI (gh) | [Docs](https://github.com/devcontainers/features) | MIT |
| ghcr.io/devcontainers/features/git:1 | latest | Git com PPA para última versão | [Docs](https://github.com/devcontainers/features) | MIT |
| ghcr.io/devcontainers/features/docker-in-docker:2 | latest | Docker dentro do container | [Docs](https://github.com/devcontainers/features) | MIT |

---

## 📖 Padrões e Especificações

| Nome | Versão | Descrição | Website | Licença |
|------|--------|-----------|---------|---------|
| POSIX | - | Padrão para sistemas operacionais Unix | [Site](https://pubs.opengroup.org/onlinepubs/9699919799/) | IEEE/Open Group |
| PEP 8 | - | Guia de estilo para código Python | [Site](https://peps.python.org/pep-0008/) | PSF |
| Conventional Commits | 1.0.0 | Especificação para mensagens de commit | [Site](https://www.conventionalcommits.org/) | CC BY 3.0 |
| Semantic Versioning | 2.0.0 | Especificação de versionamento semântico | [Site](https://semver.org/) | CC BY 3.0 |
| EditorConfig | - | Padrão de configuração de editores | [Site](https://editorconfig.org/) | BSD-2-Clause |
| Markdown | - | Linguagem de marcação leve | [Site](https://www.markdownguide.org/) | Especificação aberta |
| agents.md | - | Iniciativa para documentação para agentes autônomos | [Site](https://agents.md/) | CC0-1.0 |

---

## 🌐 Serviços Externos

| Nome | Descrição | Website | Uso no Projeto | Licença |
|------|-----------|---------|----------------|---------|
| ExplainShell | Explicação de comandos Shell | [Site](https://explainshell.com/) | Integração com Bash IDE | GPL-3.0 |
| Nodesource | Distribuições Node.js para Linux | [GitHub](https://github.com/nodesource/distributions) | Instalação Node.js 20.x LTS | MIT |
| Deadsnakes PPA | Repositório de versões Python para Ubuntu | [Launchpad](https://launchpad.net/~deadsnakes/+archive/ubuntu/ppa) | Instalação Python 3.12 | Diversas (upstream) |

---

## 📝 Resumo por Categoria

| Categoria | Quantidade | Principais |
|-----------|------------|-----------|
| Linguagens e Runtimes | 5 | Bash, Python 3.12, Node.js 20 LTS |
| CLIs Core | 11 | git, gh, docker, shellcheck, shfmt |
| Pacotes Python | 19 | pylint, black, pytest, ansible, pre-commit |
| Pacotes Node.js | 6 | markdownlint-cli, prettier, typescript |
| Utilitários Sistema | 8 | build-essential, curl, jq, vim |
| Extensões VS Code | 31 | 4 Bash, 6 Python, 3 Markdown, 4 Git, 2 AI |
| DevContainer Features | 3 | GitHub CLI, Git, Docker-in-Docker |
| Padrões | 7 | POSIX, PEP 8, Conventional Commits |
| Serviços Externos | 3 | ExplainShell, Nodesource, Deadsnakes |
| **Total** | **93** | - |

---

## 📋 Notas sobre Licenciamento

### Licenças Comuns

| Licença | Tipo | Permite Uso Comercial | Requer Atribuição | Copyleft |
|---------|------|----------------------|-------------------|----------|
| MIT | Permissiva | ✅ Sim | ✅ Sim | ❌ Não |
| Apache-2.0 | Permissiva | ✅ Sim | ✅ Sim | ❌ Não |
| GPL-3.0 | Copyleft | ✅ Sim | ✅ Sim | ✅ Sim |
| GPL-2.0 | Copyleft | ✅ Sim | ✅ Sim | ✅ Sim |
| BSD-3-Clause | Permissiva | ✅ Sim | ✅ Sim | ❌ Não |
| PSF | Permissiva | ✅ Sim | ✅ Sim | ❌ Não |
| Proprietário | Restritiva | ⚠️ Depende | ⚠️ Depende | ⚠️ Depende |

### Diretrizes de Compliance

1. **Verificação**: Sempre verifique os termos de licença antes de uso comercial
2. **Atribuição**: Mantenha avisos de copyright ao redistribuir
3. **Copyleft**: Respeite termos de licenças GPL (derivados devem usar mesma licença)
4. **Proprietário**: Ferramentas proprietárias podem requerer licença paga para uso comercial
5. **Documentação**: Mantenha este documento atualizado com novas dependências

---

## 🔄 Manutenção do Documento

### Quando Atualizar

- ✅ Novas dependências adicionadas ao projeto
- ✅ Versões de ferramentas atualizadas
- ✅ Novos serviços externos integrados
- ✅ Mudanças em licenças de ferramentas
- ✅ Remoção de dependências obsoletas

### Como Atualizar

```bash
# 1. Edite THIRDPARTY.md
# 2. Valide o Markdown
markdownlint THIRDPARTY.md

# 3. Commit seguindo convenção
git add THIRDPARTY.md
git commit -m "docs(thirdparty): atualiza lista de dependências"
```

---

## 📞 Questões sobre Licenciamento

Para dúvidas sobre licenciamento ou uso de tecnologias listadas:

1. 📖 Consulte a documentação oficial da ferramenta
2. 📄 Verifique o arquivo LICENSE no repositório da ferramenta
3. 👨‍💼 Consulte equipe jurídica (para uso comercial/corporativo)
4. 🔍 Use ferramentas como [FOSSA](https://fossa.com/) para análise de compliance

---

## 🙏 Agradecimentos

Este projeto é possível graças ao trabalho de milhares de desenvolvedores e mantenedores
das ferramentas e bibliotecas open source listadas neste documento.

Agradecemos especialmente às comunidades:

- **Linux Foundation** - Infraestrutura open source
- **Python Software Foundation** - Ecossistema Python
- **OpenJS Foundation** - Ecossistema Node.js
- **GitHub** - Plataforma de colaboração
- **Todos os mantenedores individuais** - Dedicação e excelência

---

**Última atualização**: 2025-10-11

**Versão do documento**: 2.0.0

**Mantido por**: Equipe Morpheus Aruba Tasks

---

*Este documento é fornecido para fins informativos e de compliance. Sempre consulte a
documentação oficial e termos de licença de cada tecnologia antes do uso.*
