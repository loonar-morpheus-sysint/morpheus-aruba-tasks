# Segurança e Qualidade de Código

Este documento descreve as práticas de segurança, ferramentas de validação e diretrizes para manter a qualidade do código neste repositório.

## Índice

- [Proteção de Dados Sensíveis](#proteção-de-dados-sensíveis)
- [Regras do .gitignore](#regras-do-gitignore)
- [Pre-commit Hooks](#pre-commit-hooks)
- [Ferramentas de Validação](#ferramentas-de-validação)
- [Validação de Scripts Shell](#validação-de-scripts-shell)
- [Validação de Documentação Markdown](#validação-de-documentação-markdown)
- [Práticas de Segurança em Scripts](#práticas-de-segurança-em-scripts)
- [Automação e CI/CD](#automação-e-cicd)
- [Manutenção e Atualizações](#manutenção-e-atualizações)

## Proteção de Dados Sensíveis

### Objetivo

Prevenir que informações confidenciais, credenciais e dados sensíveis sejam acidentalmente commitados no repositório.

### Camadas de Proteção

1. **`.gitignore`** - Previne adição de arquivos sensíveis
2. **`detect-secrets`** - Detecta secrets em commits
3. **`pre-commit hooks`** - Validação automática antes de commit
4. **GitHub Actions** - Validação no CI/CD

## Regras do .gitignore

O arquivo `.gitignore` está configurado para proteger automaticamente diversos tipos de arquivos sensíveis e temporários.

### 🔐 Segurança e Credenciais

#### Arquivos de Ambiente

```gitignore
.env
.env.*
!.env.example
!.env.sample
!.env.template
```

**Protege:**

- `.env` - Arquivo principal de variáveis de ambiente
- `.env.local`, `.env.production`, `.env.development` - Variantes
- **Exceções**: `.env.example`, `.env.sample`, `.env.template` (templates podem ser versionados)

#### Chaves e Certificados

```gitignore
*.key
*.pem
*.p12
*.pfx
*.cer
*.crt
*.der
*.csr
```

**Tipos protegidos:**

- `.key` - Chaves privadas
- `.pem` - Certificados PEM
- `.p12`, `.pfx` - Certificados PKCS#12
- `.cer`, `.crt` - Certificados X.509
- `.der` - Certificados DER
- `.csr` - Certificate Signing Requests

#### Arquivos de Credenciais

```gitignore
*credentials*
*password*
*secret*
!.secrets.baseline
```

**Protege qualquer arquivo com:**

- `credentials` no nome
- `password` no nome
- `secret` no nome
- **Exceção**: `.secrets.baseline` (necessário para detect-secrets)

#### Tokens e API Keys

```gitignore
*token*
*apikey*
*.keystore
```

### 📁 Arquivos Temporários

#### Extensões Temporárias

```gitignore
*.tmp
*.temp
*.bak
*.backup
*.old
*.swp
*.swo
*~
```

**Proteção contra:**

- Arquivos temporários de editores
- Backups automáticos
- Arquivos de swap do Vim

#### Diretórios Temporários

```gitignore
tmp/
temp/
.cache/
.tmp/
```

### 📝 Logs

#### Arquivos de Log

```gitignore
*.log
logs/
log/
```

#### Logs Específicos

```gitignore
npm-debug.log*
yarn-debug.log*
yarn-error.log*
lerna-debug.log*
pip-log.txt
```

### 🐍 Python (pip)

#### Cache e Bytecode

```gitignore
__pycache__/
*.py[cod]
*$py.class
*.so
```

**Ignora:**

- `__pycache__/` - Cache de bytecode Python
- `.pyc`, `.pyo`, `.pyd` - Arquivos compilados
- `$py.class` - Classes Python
- `.so` - Bibliotecas compartilhadas

#### Ambientes Virtuais

```gitignore
venv/
env/
ENV/
.venv/
virtualenv/
.Python
```

**Ambientes Python comuns:**

- `venv/` - Ambiente virtual padrão
- `env/`, `ENV/` - Variações
- `.venv/` - Ambiente oculto
- `virtualenv/` - Virtualenv
- `.Python` - Link simbólico Python

#### Build e Distribuição

```gitignore
build/
develop-eggs/
dist/
downloads/
eggs/
.eggs/
lib/
lib64/
parts/
sdist/
var/
wheels/
*.egg-info/
.installed.cfg
*.egg
MANIFEST
```

**Arquivos de build:**

- `build/`, `dist/` - Diretórios de build
- `*.egg-info/` - Metadados de pacotes
- `wheels/` - Wheel packages

#### Testes e Coverage

```gitignore
.pytest_cache/
.tox/
.coverage
.coverage.*
htmlcov/
.hypothesis/
nosetests.xml
coverage.xml
*.cover
.cache
```

**Ferramentas de teste:**

- `.pytest_cache/` - Cache do pytest
- `.tox/` - Ambientes tox
- `.coverage` - Dados de cobertura
- `htmlcov/` - Relatórios HTML de cobertura

### 📦 Node.js (npm/yarn/pnpm)

#### Dependências

```gitignore
node_modules/
jspm_packages/
bower_components/
```

#### Lock Files

```gitignore
package-lock.json
yarn.lock
pnpm-lock.yaml
```

**Por que ignorar lock files?**

Para scripts Bash, geralmente não há necessidade de versionar lock files, mas ajuste se necessário para seu projeto.

#### Cache e Runtime

```gitignore
.npm
.eslintcache
.node_repl_history
.yarn/cache
.yarn/unplugged
.yarn/build-state.yml
.yarn/install-state.gz
.pnp.*
```

#### Coverage

```gitignore
coverage/
.nyc_output
lib-cov
```

### 💻 Sistema Operacional

#### macOS

```gitignore
.DS_Store
.AppleDouble
.LSOverride
._*
.DocumentRevisions-V100
.fseventsd
.Spotlight-V100
.TemporaryItems
.Trashes
.VolumeIcon.icns
.com.apple.timemachine.donotpresent
.apdisk
```

**Arquivos do macOS:**

- `.DS_Store` - Metadados de pastas
- `._*` - Arquivos de recursos
- Diretórios de sistema do Finder

#### Windows

```gitignore
Thumbs.db
Thumbs.db:encryptable
ehthumbs.db
ehthumbs_vista.db
*.stackdump
[Dd]esktop.ini
$RECYCLE.BIN/
*.cab
*.msi
*.msix
*.msm
*.msp
*.lnk
```

**Arquivos do Windows:**

- `Thumbs.db` - Cache de thumbnails
- `Desktop.ini` - Configurações de pastas
- `$RECYCLE.BIN/` - Lixeira

#### Linux

```gitignore
*~
.fuse_hidden*
.directory
.Trash-*
.nfs*
```

### 🛠️ IDEs e Editores

#### Visual Studio Code

```gitignore
.vscode/settings.json
.vscode/tasks.json
.vscode/launch.json
.vscode/extensions.json
*.code-workspace
.history/
```

**Mantém versionado:**

- `.vscode/` (exceto arquivos específicos)
- Permite compartilhar configurações do projeto

#### JetBrains (IntelliJ, PyCharm, WebStorm, etc)

```gitignore
.idea/
*.iml
*.iws
*.ipr
out/
.idea_modules/
```

#### Vim

```gitignore
*.swp
*.swo
[._]*.s[a-v][a-z]
[._]*.sw[a-p]
[._]s[a-rt-v][a-z]
[._]ss[a-gi-z]
[._]sw[a-p]
Session.vim
Sessionx.vim
.netrwhist
tags
[._]*.un~
```

#### Emacs

```gitignore
*~
\#*\#
/.emacs.desktop
/.emacs.desktop.lock
*.elc
auto-save-list
tramp
.\#*
```

#### Sublime Text

```gitignore
*.sublime-project
*.sublime-workspace
*.tmlanguage.cache
*.tmPreferences.cache
*.stTheme.cache
*.sublime_metrics
*.sublime_session
```

### ⚡ Runtime

```gitignore
*.pid
*.seed
*.pid.lock
pids/
```

**Arquivos de processo:**

- `.pid` - Process IDs
- `.seed` - Seeds de geração
- `pids/` - Diretório de PIDs

### 📊 Estatísticas do .gitignore

**Resumo:**

- **Total de linhas**: 271
- **Categorias**: 11
- **Extensões protegidas**: 50+
- **Diretórios protegidos**: 40+

## Pre-commit Hooks

O arquivo `.pre-commit-config.yaml` configura validações automáticas antes de cada commit, garantindo qualidade e segurança do código.

### Hooks Configurados

#### 1. Hooks Gerais (pre-commit-hooks)

```yaml
- repo: https://github.com/pre-commit/pre-commit-hooks
  rev: v4.5.0
  hooks:
    - id: trailing-whitespace
    - id: end-of-file-fixer
    - id: check-yaml
    - id: check-json
    - id: check-added-large-files
      args: ['--maxkb=1000']
    - id: check-case-conflict
    - id: check-merge-conflict
    - id: detect-private-key
    - id: mixed-line-ending
      args: ['--fix=lf']
```

**Descrição de cada hook:**

| Hook | Descrição | Exemplos |
|------|-----------|----------|
| `trailing-whitespace` | Remove espaços no final das linhas | `texto    ` → `texto` |
| `end-of-file-fixer` | Garante linha vazia no final | Adiciona `\n` no EOF |
| `check-yaml` | Valida sintaxe YAML | Detecta `tab` em YAML |
| `check-json` | Valida sintaxe JSON | Vírgula extra, aspas |
| `check-added-large-files` | Bloqueia arquivos > 1MB | Previne binários grandes |
| `check-case-conflict` | Detecta conflitos de case | `file.txt` vs `File.txt` |
| `check-merge-conflict` | Encontra marcadores de merge | `<<<<<<<`, `>>>>>>>` |
| `detect-private-key` | Detecta chaves privadas | `BEGIN RSA PRIVATE KEY` |
| `mixed-line-ending` | Normaliza para LF | CRLF → LF |

#### 2. ShellCheck (shellcheck-py)

```yaml
- repo: https://github.com/shellcheck-py/shellcheck-py
  rev: v0.9.0.6
  hooks:
    - id: shellcheck
      args: ['-x', '--severity=warning']
```

**Parâmetros:**

- `-x`: Segue arquivos `source` e includes
- `--severity=warning`: Reporta warnings e erros (ignora info/style)

**Exemplos de Validações:**

```bash
# ❌ Erro: Variável não quotada
file=$1
rm $file

# ✅ Correto
file=$1
rm "$file"

# ❌ Erro: Uso incorreto de $?
comando
if [ $? -eq 0 ]; then

# ✅ Correto
if comando; then

# ❌ Erro: Variável não inicializada
if [ "$var" = "value" ]; then

# ✅ Correto
var="${var:-default}"
if [ "$var" = "value" ]; then
```

#### 3. MarkdownLint (markdownlint-cli)

```yaml
- repo: https://github.com/igorshubovych/markdownlint-cli
  rev: v0.39.0
  hooks:
    - id: markdownlint
      args: ['--config', '.markdownlint.json', '--fix']
```

**Configuração (`.markdownlint.json`):**

```json
{
  "default": true,
  "MD003": { "style": "atx" },
  "MD007": { "indent": 2 },
  "MD013": { "line_length": 120 },
  "MD024": { "siblings_only": true },
  "MD033": { "allowed_elements": ["details", "summary"] },
  "MD041": false
}
```

**Regras Principais:**

| Regra | Descrição | Exemplo |
|-------|-----------|---------|
| MD003 | Estilo de headers ATX | `# Header` não `Header\n===` |
| MD007 | Indentação de listas: 2 espaços | `  - item` |
| MD013 | Comprimento máximo: 120 chars | Quebra linhas longas |
| MD024 | Headers duplicados OK em seções diferentes | Permite múltiplos "# Introdução" |
| MD033 | HTML permitido: `<details>`, `<summary>` | Para collapsible sections |
| MD041 | Não requer H1 no início | Permite começar com texto |

#### 4. YAMLLint (yamllint)

```yaml
- repo: https://github.com/adrienverge/yamllint
  rev: v1.35.1
  hooks:
    - id: yamllint
      args: ['-d', '{extends: default, rules: {line-length: {max: 120}}}']
```

**Validações:**

- ✅ Sintaxe YAML válida
- ✅ Indentação consistente (2 espaços)
- ✅ Sem tabs
- ✅ Comprimento de linha (max 120)
- ✅ Trailing spaces
- ✅ Quebras de linha

**Exemplos:**

```yaml
# ❌ Erro: Tab usado
key:
→value

# ✅ Correto: Espaços
key:
  value

# ❌ Erro: Indentação inconsistente
list:
  - item1
   - item2

# ✅ Correto
list:
  - item1
  - item2
```

#### 5. Detect Secrets (detect-secrets)

```yaml
- repo: https://github.com/Yelp/detect-secrets
  rev: v1.4.0
  hooks:
    - id: detect-secrets
      args: ['--baseline', '.secrets.baseline']
      exclude: package-lock.json
```

**O que detecta:**

| Tipo | Exemplo |
|------|---------|
| AWS Keys | `AKIAIOSFODNN7EXAMPLE` |
| Azure Tokens | `DefaultEndpointsProtocol=https;AccountName=...` |
| GCP Keys | Service account JSON |
| Private Keys | `-----BEGIN RSA PRIVATE KEY-----` |
| JWT Tokens | `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...` |
| Passwords | `password = "secret123"` |
| API Keys | `api_key: "sk_live_..."` |
| Basic Auth | `https://user:pass@example.com` |
| Slack Tokens | `xoxb-...` |
| Stripe Keys | `sk_live_...`, `pk_live_...` |

**Baseline (`.secrets.baseline`):**

Arquivo que armazena "secrets conhecidos" (falsos positivos aprovados):

```bash
# Gerar nova baseline
detect-secrets scan --baseline .secrets.baseline

# Auditar secrets detectados
detect-secrets audit .secrets.baseline
```

#### 6. Bashate (bashate)

```yaml
- repo: https://github.com/openstack/bashate
  rev: 2.1.1
  hooks:
    - id: bashate
      args: ['--ignore=E006']
```

**Validações de Estilo:**

| Código | Descrição | Exemplo |
|--------|-----------|---------|
| E001 | Tabs em vez de espaços | Use 4 espaços |
| E002 | Mais de 1 linha vazia | Remova extras |
| E003 | Indentação não múltipla de 4 | Corrija indentação |
| E004 | Sem espaço após `#` | `#comentário` → `# comentário` |
| E005 | Linha termina com `\` e espaços | Remova trailing spaces |
| E006 | Linha muito longa (>79 chars) | **IGNORADO** neste projeto |

### Como Funcionam os Pre-commit Hooks

#### Instalação

```bash
# Automática (no dev container)
# Executado por .devcontainer/post-create.sh
pre-commit install

# Manual
pip install pre-commit
pre-commit install
```

#### Execução Automática

```bash
# Ao fazer commit, hooks executam automaticamente
git add arquivo.sh
git commit -m "feat: nova funcionalidade"

# Exemplo de saída:
Trim Trailing Whitespace.................Passed
Fix End of Files.........................Passed
Check Yaml..............................Passed
Check Json..............................Passed
Check for added large files.............Passed
Check for case conflicts................Passed
Check for merge conflicts...............Passed
Detect Private Key......................Passed
Mixed line ending.......................Passed
shellcheck..............................Passed
markdownlint............................Passed
yamllint................................Passed
detect-secrets..........................Passed
bashate.................................Passed
[main abc1234] feat: nova funcionalidade
 1 file changed, 10 insertions(+)
```

#### Execução Manual

```bash
# Executar em todos os arquivos
pre-commit run --all-files

# Executar hook específico
pre-commit run shellcheck --all-files
pre-commit run markdownlint --all-files

# Executar em arquivos específicos
pre-commit run --files script.sh README.md

# Pular hooks (NÃO RECOMENDADO!)
git commit --no-verify -m "Mensagem"
```

### Fluxo de Validação

```text
┌─────────────────┐
│  git add files  │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  git commit     │
└────────┬────────┘
         │
         ▼
┌─────────────────────────────────────┐
│  Pre-commit hooks executam          │
│  ┌─────────────────────────────┐   │
│  │ 1. trailing-whitespace      │   │
│  │ 2. end-of-file-fixer        │   │
│  │ 3. check-yaml               │   │
│  │ 4. check-json               │   │
│  │ 5. check-added-large-files  │   │
│  │ 6. detect-private-key       │   │
│  │ 7. shellcheck               │   │
│  │ 8. markdownlint             │   │
│  │ 9. yamllint                 │   │
│  │ 10. detect-secrets          │   │
│  │ 11. bashate                 │   │
│  └─────────────────────────────┘   │
└────────┬────────────────────────────┘
         │
         ├─── ✅ Todos passaram
         │         │
         │         ▼
         │    ┌────────────────┐
         │    │ Commit criado  │
         │    └────────────────┘
         │
         └─── ❌ Algum falhou
                   │
                   ▼
              ┌──────────────────────┐
              │ Commit bloqueado     │
              │ Corrija os problemas │
              └──────────────────────┘
```

## Ferramentas de Validação

### ShellCheck - Validação de Scripts Bash

**Instalação:**

```bash
# Ubuntu/Debian
sudo apt-get install shellcheck

# macOS
brew install shellcheck

# Fedora
sudo dnf install shellcheck
```

**Uso:**

```bash
# Validar um script
shellcheck script.sh

# Validar todos os scripts
shellcheck *.sh

# Validar com severidade específica
shellcheck -S warning script.sh

# Seguir includes
shellcheck -x script.sh

# Formato de saída
shellcheck -f json script.sh > report.json
shellcheck -f gcc script.sh  # Para integração com IDEs
```

**Níveis de Severidade:**

- `error` - Erros que causam problemas
- `warning` - Avisos de más práticas
- `info` - Informações úteis
- `style` - Sugestões de estilo

### MarkdownLint - Validação de Documentação

**Instalação:**

```bash
# Via npm
npm install -g markdownlint-cli

# Via yarn
yarn global add markdownlint-cli
```

**Uso:**

```bash
# Validar um arquivo
markdownlint README.md

# Validar todos os Markdown
markdownlint '**/*.md'

# Corrigir automaticamente
markdownlint --fix documento.md

# Usar configuração específica
markdownlint -c .markdownlint.json *.md

# Ignorar arquivos
markdownlint --ignore node_modules '**/*.md'
```

## Práticas de Segurança em Scripts

### 1. Validação de Entrada

```bash
# ✅ Sempre valide parâmetros
validate_input() {
  local input=$1
  
  if [[ -z "$input" ]]; then
    log_error "Parâmetro obrigatório não fornecido"
    return 1
  fi
  
  # Valide padrão esperado
  if [[ ! "$input" =~ ^[a-zA-Z0-9_-]+$ ]]; then
    log_error "Entrada contém caracteres inválidos"
    return 1
  fi
  
  return 0
}

# ✅ Use com todas as entradas do usuário
if validate_input "$user_input"; then
  process_input "$user_input"
fi
```

### 2. Uso Seguro de Credenciais

```bash
# ❌ NUNCA faça isso
PASSWORD="minha_senha_123"
API_KEY="sk_live_1234567890"

# ✅ Use variáveis de ambiente
if [[ -z "$ARUBA_PASSWORD" ]]; then
  log_error "ARUBA_PASSWORD não definida"
  exit 1
fi

# ✅ Ou leia de arquivo seguro
if [[ -f "$HOME/.aruba_credentials" ]]; then
  # shellcheck source=/dev/null
  source "$HOME/.aruba_credentials"
fi

# ✅ Ou solicite interativamente (sem echo)
read -rsp "Digite a senha: " password
echo ""  # Nova linha após input
```

### 3. Prevenção de Command Injection

```bash
# ❌ Vulnerável a injection
user_input=$1
eval "echo $user_input"  # NUNCA use eval com input de usuário

# ✅ Use alternativas seguras
user_input=$1
echo "$user_input"  # Sempre quote variáveis

# ❌ Perigoso
filename=$1
rm $filename  # Pode executar rm -rf / se filename="-rf /"

# ✅ Seguro
filename=$1
if [[ -f "$filename" ]]; then
  rm "$filename"
fi

# ✅ Ainda melhor: valide primeiro
filename=$1
if [[ "$filename" =~ ^[a-zA-Z0-9._-]+$ ]] && [[ -f "$filename" ]]; then
  rm "$filename"
fi
```

### 4. Permissões de Arquivo

```bash
# Arquivos de configuração sensíveis
chmod 600 config/credentials.conf  # rw-------

# Scripts executáveis
chmod 750 scripts/*.sh  # rwxr-x---

# Logs (legível por grupo)
chmod 640 logs/*.log  # rw-r-----

# Diretórios
chmod 700 ~/.ssh  # rwx------
chmod 755 /usr/local/bin/script.sh  # rwxr-xr-x
```

### 5. Logging Seguro

```bash
# ❌ Não logue credenciais
log_info "Conectando com senha: $PASSWORD"

# ✅ Logue apenas informações não sensíveis
log_info "Conectando ao servidor $HOST como $USER"

# ✅ Mascare dados sensíveis se necessário
masked_password="${PASSWORD:0:2}***${PASSWORD: -2}"
log_debug "Senha configurada: $masked_password"
```

## Automação e CI/CD

### GitHub Actions

O arquivo `.github/workflows/validation.yml` executa todas as validações no CI/CD.

**Triggers:**

```yaml
on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main, develop ]
```

**Jobs:**

1. **Checkout code** - Clona o repositório
2. **Setup Python** - Instala Python 3.11
3. **Setup Node.js** - Instala Node.js 20
4. **Install tools** - Instala shellcheck, markdownlint, yamllint, detect-secrets
5. **Run validations** - Executa todas as validações
6. **Report results** - Gera resumo

**Proteção de Branch:**

Configure no GitHub:

1. Settings → Branches → Branch protection rules
2. Add rule para `main`
3. Habilite:
   - Require status checks to pass
   - Require branches to be up to date
   - Status checks: "Validate Code Quality"

## Manutenção e Atualizações

### Checklist Pré-Commit

Antes de cada commit:

- [ ] Scripts `.sh` validados com shellcheck
- [ ] Arquivos `.md` validados com markdownlint
- [ ] Nenhuma credencial sendo commitada
- [ ] Mensagem de commit descritiva
- [ ] Documentação atualizada
- [ ] Pre-commit hooks passaram

### Atualização de Ferramentas

#### Pre-commit

```bash
# Atualizar versões dos hooks
pre-commit autoupdate

# Reinstalar hooks
pre-commit install --install-hooks
```

#### ShellCheck

```bash
# Ubuntu/Debian
sudo apt-get update && sudo apt-get upgrade shellcheck

# macOS
brew upgrade shellcheck
```

#### MarkdownLint

```bash
# npm
npm update -g markdownlint-cli

# yarn
yarn global upgrade markdownlint-cli
```

### Auditoria Periódica

Execute mensalmente:

```bash
# 1. Validar todo o repositório
pre-commit run --all-files

# 2. Atualizar baseline de secrets
detect-secrets scan --baseline .secrets.baseline

# 3. Auditar secrets detectados
detect-secrets audit .secrets.baseline

# 4. Buscar padrões sensíveis manualmente
grep -r "password\|token\|secret\|key" \
  --include="*.sh" \
  --include="*.md" \
  --exclude-dir=node_modules \
  --exclude-dir=.git

# 5. Verificar permissões de arquivos
find . -type f -perm /go+w -ls  # Arquivos graváveis por outros
```

## Recursos Adicionais

### Documentação Oficial

- [ShellCheck Wiki](https://github.com/koalaman/shellcheck/wiki)
- [MarkdownLint Rules](https://github.com/DavidAnson/markdownlint/blob/main/doc/Rules.md)
- [Pre-commit Hooks](https://pre-commit.com/)
- [Detect Secrets](https://github.com/Yelp/detect-secrets)
- [OWASP Shell Security](https://cheatsheetseries.owasp.org/cheatsheets/OS_Command_Injection_Defense_Cheat_Sheet.html)

### Guias de Estilo

- [Google Shell Style Guide](https://google.github.io/styleguide/shellguide.html)
- [Bash Best Practices](https://mywiki.wooledge.org/BashGuide/Practices)
- [Markdown Style Guide](https://www.markdownguide.org/basic-syntax/)

### Referências Internas

- [AGENTS.md](./AGENTS.md) - Padrões de desenvolvimento
- [SETUP.md](./SETUP.md) - Guia de configuração
- [README.md](./README.md) - Visão geral do projeto

---

**Última Atualização**: 2025-10-11

**Mantenedores**: Equipe DevOps Morpheus

**Contato**: Para questões de segurança, abra uma issue confidencial ou entre em contato com a equipe de segurança.
