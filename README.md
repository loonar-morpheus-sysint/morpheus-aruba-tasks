# morpheus-aruba-tasks

> **⚠️ WIP - Work in Progress**
> Este projeto está em desenvolvimento ativo. Funcionalidades e documentação podem sofrer alterações.

![LoonarBR cover](./_assets/loonarbr_cover.jpeg)

## Descrição

Repositório de scripts em Bash para automatização de tarefas administrativas em switches Aruba da HPE. Esses scripts são projetados para serem executados como tarefas no Morpheus Data, permitindo a criação de itens no catálogo de aplicações de autoatendimento.

Este repositório é AI Powered — inclui configurações e integrações para assistência de código e terminal (GitHub Copilot e Aider) diretamente no Dev Container.

## 🚀 Dev Container (inclui integrações AI)

O Dev Container do projeto contém um ambiente pronto para desenvolvimento com suporte para assistência de código e terminal (AI Powered). Ao abrir o workspace no VS Code o container é construído com ferramentas, extensões e configurações para GitHub Copilot e Aider.

### Pré-requisitos

- Docker instalado
- Visual Studio Code com extensão "Dev Containers"
- WSL2 configurado (para Windows)
- Git e GitHub CLI configurados no WSL

### Abrindo o Projeto

1. Clone o repositório:

```bash
git clone https://github.com/loonar-morpheus-sysint/morpheus-aruba-tasks.git
cd morpheus-aruba-tasks
```

2. Abra no VS Code:

```bash
code .
```

3. Quando solicitado, clique em "Reopen in Container" ou use o comando:
   - `Ctrl+Shift+P` → "Dev Containers: Reopen in Container"

O container será construído automaticamente com as ferramentas e integrações listadas abaixo. Ele já inclui configurações para fornecer suporte AI (GitHub Copilot + Aider) sem configuração adicional.

### Ferramentas e extensões incluídas

- **Extensões VS Code**: 36 extensões incluindo Shellcheck, Bash Debug, Python (Pylance, Black, Flake8), Markdownlint, GitHub Copilot, GitHub Copilot Chat, GitHub Actions, GitLens, Docker, BATS Test Runner e muitas outras
- **CLI Tools**: shellcheck, shfmt, markdownlint, yamllint, detect-secrets, pre-commit, gh (GitHub CLI), python3, node.js, npm, pip, bats
- **Python Tools**: pylint, flake8, black, mypy, pytest, ansible, ipython e mais
- **Node.js Tools**: prettier, eslint, typescript, bash-language-server
- **Watcher/automation**: `watch-agents.sh`, `generate-copilot-instructions.sh` (regeneram instruções Copilot a partir de `AGENTS.md`)

### Aider & Copilot — papéis

- GitHub Copilot: assistente de código integrado ao editor (sugestões e completions)
- Aider: ferramenta AI de linha de comando / REPL para workflows de refatoração e geração de código com contexto do projeto

### Iniciar Aider (opcional)

```bash
# Validar instalação
./validate-aider.sh

# Iniciar Aider
aider

# Com contexto do projeto
aider AGENTS.md commons.sh
```

Documentação do Aider: [AIDER_QUICKSTART.md](./AIDER_QUICKSTART.md) | [AIDER_SETUP.md](./AIDER_SETUP.md)

## ✅ Validações Automáticas

### Pre-commit Hooks

O projeto utiliza pre-commit para validações automáticas antes de cada commit:

- **Shellcheck**: Valida scripts Bash
- **Markdownlint**: Valida formatação de Markdown
- **YAML Lint**: Valida arquivos YAML
- **JSON Validator**: Valida sintaxe JSON
- **Detect Secrets**: Detecta credenciais e informações sensíveis
- **Commit Messages**: Valida mensagens de commit semânticas (Conventional Commits)
- **BATS Tests**: Executa testes automatizados dos scripts (veja [TESTING.md](./TESTING.md))
- **Formatação**: Remove espaços em branco, adiciona quebra de linha final

### Executando Validações Manualmente

```bash
# Validar todos os arquivos
pre-commit run --all-files

# Validar apenas arquivos modificados
pre-commit run

# Validar script específico
shellcheck seu-script.sh

# Validar Markdown específico
markdownlint seu-arquivo.md
```

### GitHub Actions

Todas as validações são executadas automaticamente no GitHub Actions para:

- Push na branch `main`
- Push na branch `develop`
- Pull requests para `main` ou `develop`

**Proteção**: Merges para `main` são bloqueados se as validações falharem.

## 🛠️ Ferramentas Instaladas no Dev Container

### Extensões VS Code

#### Desenvolvimento Shell/Bash

- **Shellcheck**: Linting para Bash
- **Bash Debug**: Debugging de scripts Bash
- **Shell Format**: Formatação automática de scripts
- **Bash IDE**: IDE features para Bash

#### Desenvolvimento Python

- **Python**: Suporte Python completo
- **Pylance**: Language server Python de alta performance
- **Pylint**: Integração pylint
- **Flake8**: Integração flake8
- **Black Formatter**: Formatação automática
- **Python Debugger**: Debugging Python

#### Markdown e Documentação

- **Markdownlint**: Validação de Markdown
- **Markdown All in One**: Ferramentas completas para Markdown
- **Markdown Preview GitHub Styles**: Preview estilo GitHub
- **Markdown Notebook**: Notebooks Markdown

#### Git e GitHub

- **GitHub Pull Requests**: Gerenciamento de PRs
- **GitHub Actions**: Suporte para workflows
- **GitLens**: Recursos avançados Git
- **Git History**: Visualização de histórico Git
- **Git Hooks**: Gerenciamento de hooks

#### AI Assistants

- **GitHub Copilot**: Assistente de código IA
- **GitHub Copilot Chat**: Chat com IA para programação

#### Qualidade e Formatação

- **EditorConfig**: Suporte EditorConfig
- **Prettier**: Formatação de código
- **Error Lens**: Destaque de erros inline
- **Code Spell Checker**: Verificador ortográfico

#### Utilitários e Produtividade

- **Better Comments**: Comentários categorizados
- **TODO Highlight**: Destaque de TODOs
- **TODO Tree**: Visualização em árvore de TODOs
- **Toggle Terminal**: Controle de terminal na status bar

#### DevOps e Containers

- **Docker**: Suporte Docker
- **Remote Containers**: Desenvolvimento em containers
- **YAML**: Suporte para YAML
- **XML**: Suporte para XML

#### Testes e Segurança

- **BATS**: Suporte para testes BATS
- **BATS Test Runner**: Execução de testes BATS
- **Snyk Security**: Scanner de vulnerabilidades

#### Outros

- **Ivy**: Ferramenta adicional de produtividade

### CLI Tools

#### Core Development Tools

- `git`: Sistema de controle de versão
- `gh`: GitHub CLI (com autenticação do WSL)
- `docker`: Plataforma de containerização

#### Shell e Script Development

- `shellcheck`: Validador de scripts Shell
- `shfmt`: Formatador de scripts Shell
- `bats`: Framework de testes para Bash

#### Python Development

- `python3`: Python 3.11 com pip
- `pipx`: Gerenciador de ferramentas Python isoladas
- `pre-commit`: Framework de hooks Git
- `detect-secrets`: Detector de segredos
- `pylint`: Linter para Python
- `flake8`: Verificador de estilo Python
- `black`: Formatador de código Python
- `mypy`: Verificador de tipos estáticos
- `pytest`: Framework de testes Python
- `ansible`: Ferramenta de automação
- `ipython`: Shell Python interativo

#### Node.js Development

- `node`: Node.js 20.x LTS
- `npm`: Gerenciador de pacotes Node.js
- `markdownlint-cli`: Validador de Markdown
- `prettier`: Formatador de código
- `eslint`: Linter para JavaScript/TypeScript
- `typescript`: Superset tipado de JavaScript
- `bash-language-server`: Language server para Bash

#### File Processing e Utilities

- `yamllint`: Validador de YAML
- `jq`: Processador JSON
- `curl`: Cliente HTTP
- `wget`: Download de arquivos
- `vim`: Editor de texto
- `nano`: Editor de texto simples

## 📋 Padrões de Código

Consulte [AGENTS.md](./AGENTS.md) para diretrizes completas de desenvolvimento.

Consulte [COMMIT_CONVENTION.md](./COMMIT_CONVENTION.md) para padrões de mensagens de commit.

Consulte [TESTING.md](./TESTING.md) para configuração e execução de testes automatizados.

Consulte [WATCHER.md](./WATCHER.md) para configuração do monitoramento automático do AGENTS.md.

Consulte [COPILOT_INTEGRATION.md](./COPILOT_INTEGRATION.md) para detalhes sobre a integração com GitHub Copilot.

## 🤖 GitHub Copilot - Instruções Customizadas

O projeto está configurado para fornecer **instruções customizadas automaticamente** ao GitHub Copilot.

### Funcionamento da Integração

1. 📝 Você edita `AGENTS.md` (padrões do projeto em português)
2. 🔍 Watcher detecta a mudança automaticamente
3. 🌍 Script traduz o conteúdo para inglês
4. 📄 Gera `.github/copilot-instructions.md` (lido automaticamente pelo Copilot)
5. ✨ GitHub Copilot passa a seguir os padrões do projeto!

### Benefícios

✅ **Código consistente**: Copilot gera código seguindo AGENTS.md
✅ **Zero configuração**: Funciona automaticamente no devcontainer
✅ **Sempre atualizado**: Mudanças em AGENTS.md refletem em ~5 segundos
✅ **Nomenclatura correta**: Variáveis em português, kebab-case para arquivos
✅ **Estrutura obrigatória**: Headers, logging, main function

### Testar

```bash
# Verificar arquivo de instruções
ls -lh .github/copilot-instructions.md

# Ver quando foi atualizado
stat .github/copilot-instructions.md

# Perguntar ao Copilot sobre o projeto
# No VS Code: Ctrl+Shift+P → "Copilot Chat"
# Pergunta: "What are the naming conventions for this project?"
```

Para mais detalhes, consulte [COPILOT_INTEGRATION.md](./COPILOT_INTEGRATION.md).

## 👁️ AGENTS.md File Watcher (Automático)

O projeto inclui um **file watcher** que monitora automaticamente mudanças no arquivo `AGENTS.md` e regenera as instruções do GitHub Copilot.

### Como Funciona

Quando você edita e salva o `AGENTS.md`:

1. 🔍 O watcher detecta a mudança instantaneamente
2. ⏱️ Aguarda 2 segundos (debounce) para estabilizar
3. 🔄 Executa `generate-copilot-instructions.sh` automaticamente
4. ✅ Atualiza `copilot-codegen-instructions.json` com novo conteúdo traduzido

### Comandos Úteis

```bash
# Verificar status
./watch-agents.sh --status

# Ver logs em tempo real
tail -f logs/watch-agents.log

# Parar watcher (se necessário)
./watch-agents.sh --stop

# Reiniciar watcher
./watch-agents.sh --background
```

**Nota:** O watcher é iniciado **automaticamente** quando o devcontainer é criado. Você não precisa fazer nada!

Para mais detalhes, consulte [WATCHER.md](./WATCHER.md).

**Checklist antes de commit**:

- [ ] Todos os scripts `.sh` passam no shellcheck
- [ ] Todos os arquivos `.md` passam no markdownlint
- [ ] Testes BATS estão passando (execute `./run-tests.sh`)
- [ ] Nenhuma credencial está sendo commitada
- [ ] Mensagem de commit segue padrão semântico (feat:, fix:, docs:, etc.)
- [ ] Documentação atualizada

## 🔒 Segurança

Consulte [SECURITY.md](./SECURITY.md) para práticas de segurança e qualidade de código.

## Por que CLI em vez de API?

Este repositório utiliza a CLI (Command Line Interface) da solução Aruba para acesso e manipulação dos switches. A escolha da CLI em vez da API REST foi feita pelos seguintes motivos:

- **Simplicidade**: A CLI é mais direta e integrada naturalmente em scripts Bash, sem necessidade de bibliotecas ou ferramentas adicionais
- **Facilidade de integração**: Scripts Bash podem executar comandos CLI de forma nativa usando SSH, simplificando o fluxo de trabalho
- **Menor complexidade**: Não requer parsing de JSON, manipulação de tokens de autenticação OAuth, ou gerenciamento de dependências externas como `curl` ou `jq`
- **Debugging simplificado**: Comandos CLI são mais fáceis de testar e depurar interativamente

Por outro lado, as APIs REST da Aruba exigem:

- Autenticação mais complexa (tokens, sessões)
- Parsing e manipulação de dados JSON
- Tratamento de códigos de status HTTP
- Dependências externas para processar respostas

Para cenários de automação simples e diretos em Bash, a CLI oferece uma solução mais pragmática e de fácil manutenção.

## 🙏 Agradecimentos à Comunidade Open Source

Este projeto é possível graças ao **extraordinário trabalho** de milhares de desenvolvedores e mantenedores da comunidade open source mundial. Nossa solução depende fundamentalmente de código aberto.

### 📊 Dependência de Código Aberto - Análise Quantitativa

Com base no levantamento completo documentado em [THIRDPARTY.md](./THIRDPARTY.md), nossa solução utiliza:

| Categoria | Quantidade | % Open Source | Principais Tecnologias |
|-----------|------------|---------------|----------------------|
| **Linguagens e Runtimes** | 5 | 100% | Bash, Python, Node.js, npm, pip |
| **CLI Tools Essenciais** | 12 | 100% | git, shellcheck, shfmt, bats, curl, jq, vim |
| **Pacotes Python** | 19 | 100% | pylint, black, pytest, ansible, pre-commit |
| **Pacotes Node.js** | 6 | 100% | markdownlint-cli, prettier, typescript, eslint |
| **Utilitários Sistema** | 8 | 100% | build-essential, curl, jq, vim, nano |
| **Extensões VS Code** | 36 | ~75% | 27 extensões open source de 36 totais |
| **DevContainer Features** | 4 | 100% | Todas as features são open source |
| **Padrões e Especificações** | 7 | 100% | POSIX, PEP 8, Conventional Commits, Markdown |

#### 🧮 Resultado Final

**📈 Dependência Total de Open Source: ~95%**

- **Total de tecnologias**: 100
- **Open Source**: ~95 tecnologias
- **Proprietárias/Comerciais**: ~5 tecnologias (principalmente extensões Microsoft/GitHub)

### 💝 Agradecimentos Especiais

Expressamos nossa **profunda gratidão** às seguintes comunidades e organizações:

#### 🌟 Fundações e Organizações

- **Linux Foundation** - Infraestrutura e governança do ecossistema Linux/POSIX
- **Python Software Foundation (PSF)** - Linguagem Python e todo seu ecossistema
- **OpenJS Foundation** - Node.js, npm e ferramentas JavaScript/TypeScript
- **Free Software Foundation (GNU)** - Bash, ferramentas GNU essenciais
- **Docker Inc.** - Tecnologia de containerização
- **Projeto Debian/Ubuntu** - Sistema operacional base e repositórios

#### 🔧 Ferramentas Críticas e Seus Mantenedores

- **Koalaman (ShellCheck)** - Análise estática para Bash, essencial para qualidade
- **Bats-core Team** - Framework de testes para Bash
- **Pre-commit Team** - Automação de qualidade de código
- **Black Team** - Formatação consistente de código Python
- **Ansible Team (Red Hat)** - Automação de infraestrutura
- **Prettier Team** - Formatação universal de código
- **GitLens/Eric Amodio** - Ferramentas avançadas Git
- **David Anson** - Markdownlint, padronização de documentação

#### 🏗️ Infraestrutura de Desenvolvimento

- **GitHub** - Plataforma de colaboração e CI/CD
- **Microsoft DevContainers** - Ambientes de desenvolvimento padronizados
- **VS Code Extension Authors** - Ecossistema de 36 extensões utilizadas

### 🌍 Impacto da Filosofia Open Source

Nossa solução demonstra o **poder transformador** do software livre:

1. **🚀 Inovação Acelerada**: Baseamos em décadas de desenvolvimento coletivo
2. **🔒 Segurança Transparente**: Código auditável pela comunidade global
3. **💰 Eficiência Econômica**: Reutilização de soluções maduras e testadas
4. **🤝 Colaboração Global**: Participamos do ecossistema mundial de desenvolvimento
5. **📚 Conhecimento Compartilhado**: Contribuímos de volta através de documentação e exemplos

### 🎯 Nosso Compromisso

Como beneficiários da comunidade open source, assumimos o compromisso de:

- ✅ **Documentar** nossas práticas e padrões para outros desenvolvedores
- ✅ **Compartilhar** soluções e melhorias quando possível
- ✅ **Manter** transparência sobre dependências e licenças
- ✅ **Contribuir** com feedback e bug reports para projetos upstream
- ✅ **Educar** sobre boas práticas de desenvolvimento e automação

---

**🌟 "Se vi mais longe, foi porque me apoiei sobre os ombros de gigantes."** - Isaac Newton

*Esta citação resume perfeitamente nossa relação com a comunidade open source: nosso sucesso é construído sobre as contribuições extraordinárias de milhares de desenvolvedores ao redor do mundo.*

---

## Referências

### Documentação Oficial

- **CLI Aruba HPE (ArubaOS-CX)**: [HPE Aruba Networking Command Line Interface Reference](https://www.arubanetworks.com/techdocs/AOS-CX/10.13/HTML/cli_reference/)
- **API REST Aruba HPE**: [HPE Aruba Networking REST API Guide](https://www.arubanetworks.com/techdocs/AOS-CX/10.13/HTML/rest_api_guide/)
- **Página de Marketing Aruba HPE**: [HPE Aruba Networking Solutions](https://www.arubanetworks.com/products/switches/)

---

**Nota**: Este repositório é mantido para uso com o Morpheus Data e está em desenvolvimento contínuo.
