# Guia de Configuração - Morpheus Aruba Tasks

Este documento descreve a estrutura do repositório e como utilizar as ferramentas de desenvolvimento e validação.

## 📁 Estrutura do Repositório

```text
morpheus-aruba-tasks/
├── .devcontainer/              # Configuração do Development Container
│   ├── devcontainer.json       # Configuração principal do dev container
│   ├── Dockerfile              # Imagem Docker customizada
│   └── post-create.sh          # Script executado após criação do container
│
├── .github/
│   └── workflows/
│       └── validation.yml      # Pipeline CI/CD de validação
│
├── .pre-commit-config.yaml     # Configuração dos hooks pre-commit
├── .markdownlint.json          # Regras de validação Markdown
├── .shellcheckrc               # Configuração do shellcheck
├── .secrets.baseline           # Baseline de detecção de secrets
├── .gitignore                  # Arquivos ignorados pelo Git
│
├── AGENTS.md                   # Guia para agentes de código (AI/Humanos)
├── SECURITY.md                 # Práticas de segurança
├── README.md                   # Documentação principal
├── LICENSE                     # Licença do projeto
│
├── commons.sh                  # Biblioteca de funções comuns
├── install-aruba-cli.sh        # Instalador da CLI Aruba
├── aruba-auth.sh               # Script de autenticação
├── create-vrf.sh               # Script de criação de VRF
└── .env-sample                 # Exemplo de variáveis de ambiente
```

## 🚀 Começando

### Opção 1: Usando Dev Container (Recomendado)

1. **Pré-requisitos**:
   - Docker instalado
   - VS Code com extensão "Dev Containers"
   - Git configurado

2. **Abrir o projeto**:

```bash
# Clone o repositório
git clone https://github.com/loonar-morpheus-sysint/morpheus-aruba-tasks.git
cd morpheus-aruba-tasks

# Abra no VS Code
code .

# No VS Code:
# Ctrl+Shift+P → "Dev Containers: Reopen in Container"
```

3. **O que acontece automaticamente**:
   - ✅ Instalação de todas as ferramentas (shellcheck, markdownlint, etc.)
   - ✅ Configuração de extensões VS Code
   - ✅ Instalação de hooks pre-commit
   - ✅ Sincronização de credenciais Git/GitHub do WSL

### Opção 2: Instalação Manual

Se preferir não usar o dev container:

```bash
# Instalar shellcheck
sudo apt-get install shellcheck

# Instalar Node.js e markdownlint
curl -fsSL https://deb.nodesource.com/setup_lts.x | bash -
sudo apt-get install -y nodejs
npm install -g markdownlint-cli

# Instalar Python e ferramentas
sudo apt-get install python3 python3-pip yamllint
pip3 install pre-commit detect-secrets

# Instalar hooks
pre-commit install
```

## ✅ Validações Implementadas

### 1. Pre-commit Hooks (Local)

Executados automaticamente antes de cada commit:

| Validação | Ferramenta | Descrição |
|-----------|-----------|-----------|
| Scripts Shell | shellcheck | Análise estática de código Bash |
| Markdown | markdownlint | Formatação e estilo de documentação |
| YAML | yamllint | Validação de sintaxe YAML |
| JSON | check-json | Validação de sintaxe JSON |
| Secrets | detect-secrets | Detecção de credenciais |
| Commit Messages | conventional-pre-commit | Mensagens semânticas (Conventional Commits) |
| Formatação | pre-commit-hooks | Espaços, finais de linha, etc. |

### 2. GitHub Actions (CI/CD)

Executados em push/PR para `main` e `develop`:

- ✅ Validação de todos os scripts shell
- ✅ Validação de toda a documentação
- ✅ Verificação de segredos
- ✅ Validação de arquivos YAML/JSON
- ✅ Execução de todos os hooks pre-commit

**Proteção**: PRs com falhas de validação não podem ser merged.

## 🛠️ Ferramentas Disponíveis

### Extensões VS Code (no Dev Container)

- `timonwong.shellcheck` - Linting de Bash em tempo real
- `rogalmic.bash-debug` - Debug de scripts Bash
- `davidanson.vscode-markdownlint` - Linting de Markdown
- `github.copilot` - Assistente de IA
- `github.copilot-chat` - Chat com IA
- `github.vscode-github-actions` - Suporte a workflows
- `redhat.vscode-yaml` - Suporte a YAML
- `foxundermoon.shell-format` - Formatação de scripts

### CLI Tools

```bash
# Validar script específico
shellcheck meu-script.sh

# Validar Markdown
markdownlint README.md

# Corrigir Markdown automaticamente
markdownlint --fix documento.md

# Validar YAML
yamllint .pre-commit-config.yaml

# Executar todas as validações
pre-commit run --all-files

# Atualizar baseline de secrets
detect-secrets scan --baseline .secrets.baseline
```

## 📋 Workflow de Desenvolvimento

### 1. Criar Nova Branch

```bash
git checkout -b feature/minha-feature
```

### 2. Fazer Mudanças

Edite os arquivos necessários seguindo:
- [AGENTS.md](./AGENTS.md) - Padrões de código
- [SECURITY.md](./SECURITY.md) - Práticas de segurança
- [COMMIT_CONVENTION.md](./COMMIT_CONVENTION.md) - Padrão de mensagens de commit

### 3. Validar Localmente

```bash
# Validação automática ao commitar (inclui validação de mensagem)
git add .
git commit -m "feat: minha nova feature"

# Ou validar manualmente antes
pre-commit run --all-files
```

**Importante**: A mensagem de commit deve seguir o padrão semântico:

- `feat:` para novas funcionalidades
- `fix:` para correções
- `docs:` para documentação
- Veja [COMMIT_CONVENTION.md](./COMMIT_CONVENTION.md) para detalhes

### 4. Push e Pull Request

```bash
git push origin feature/minha-feature

# Criar PR no GitHub
gh pr create --title "Feat: Minha nova feature" --body "Descrição..."
```

### 5. Validação Automática

- GitHub Actions executa todas as validações
- Se passar ✅ → PR pode ser aprovado
- Se falhar ❌ → Corrija os problemas

## 🔧 Comandos Úteis

### Validação

```bash
# Validar todos os scripts
find . -name "*.sh" -exec shellcheck {} +

# Validar todos os Markdown
markdownlint '**/*.md'

# Executar pre-commit manualmente
pre-commit run --all-files

# Pular hooks (não recomendado!)
git commit --no-verify -m "Mensagem"
```

### Debugging

```bash
# Ver configuração do pre-commit
pre-commit --version
pre-commit sample-config

# Limpar cache do pre-commit
pre-commit clean

# Reinstalar hooks
pre-commit uninstall
pre-commit install
```

### Secrets

```bash
# Gerar nova baseline
detect-secrets scan --baseline .secrets.baseline

# Auditar secrets detectados
detect-secrets audit .secrets.baseline
```

## 🚨 Troubleshooting

### Pre-commit não está executando

```bash
# Reinstalar hooks
pre-commit uninstall
pre-commit install

# Verificar instalação
ls -la .git/hooks/pre-commit
```

### Shellcheck reporta muitos erros

```bash
# Validar com severidade menor
shellcheck -S info script.sh

# Desabilitar regra específica no código
# shellcheck disable=SC2086
comando sem aspas
```

### Markdownlint muito rigoroso

Edite `.markdownlint.json` para ajustar regras:

```json
{
  "MD013": { "line_length": 120 },
  "MD041": false
}
```

### Dev Container não inicia

```bash
# Reconstruir container
# No VS Code: Ctrl+Shift+P → "Dev Containers: Rebuild Container"

# Verificar logs
# No VS Code: View → Output → Select "Dev Containers"
```

## 📚 Documentação Adicional

- [AGENTS.md](./AGENTS.md) - Padrões para desenvolvimento
- [SECURITY.md](./SECURITY.md) - Segurança e qualidade
- [README.md](./README.md) - Visão geral do projeto

## 🤝 Contribuindo

1. Leia [AGENTS.md](./AGENTS.md)
2. Siga os padrões estabelecidos
3. Execute validações localmente
4. Crie PR com descrição clara
5. Aguarde aprovação do CI/CD

## 📝 Notas Importantes

- ⚠️ **NUNCA** comite credenciais ou secrets
- ✅ **SEMPRE** execute validações antes de push
- 📖 **SEMPRE** mantenha documentação atualizada
- 🔒 **SEMPRE** use variáveis de ambiente para dados sensíveis

---

**Última Atualização**: 2025-10-11

**Mantenedores**: Equipe DevOps Morpheus
