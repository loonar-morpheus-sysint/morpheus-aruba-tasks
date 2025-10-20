# AI Support - Aider Integration

Este diretório contém todos os arquivos de suporte para integração com Aider AI.

## 📁 Estrutura

```text
ai-support/
├── scripts/          # Scripts de suporte ao Aider
│   ├── aider-start.sh
│   ├── fix-aider-auth.sh
│   ├── setup-github-token.sh
│   └── validate-aider.sh
├── docs/             # Documentação do Aider
│   ├── AIDER_SETUP.md
│   ├── AIDER_QUICKSTART.md
│   ├── AIDER_INTEGRATION.md
│   └── GITHUB_TOKEN_QUICKSTART.md
└── config/           # Arquivos de configuração
    └── .aider.conf.yml
```

## 🚀 Scripts Disponíveis

### `scripts/aider-start.sh`

Inicia o Aider com configurações otimizadas para GitHub Copilot.

**Uso:**

```bash
./ai-support/scripts/aider-start.sh
# Ou via symlink na raiz:
./aider-start.sh
```

### `scripts/setup-github-token.sh`

Configura o token do GitHub para uso com Aider.

**Uso:**

```bash
source ./ai-support/scripts/setup-github-token.sh
```

### `scripts/validate-aider.sh`

Valida a instalação e configuração do Aider.

**Uso:**

```bash
./ai-support/scripts/validate-aider.sh
# Ou via symlink na raiz:
./validate-aider.sh
```

### `scripts/fix-aider-auth.sh`

Corrige problemas de autenticação do Aider.

**Uso:**

```bash
./ai-support/scripts/fix-aider-auth.sh
```

## 📖 Documentação

- [`docs/AIDER_SETUP.md`](docs/AIDER_SETUP.md) - Guia completo de configuração
- [`docs/AIDER_QUICKSTART.md`](docs/AIDER_QUICKSTART.md) - Guia rápido de início
- [`docs/AIDER_INTEGRATION.md`](docs/AIDER_INTEGRATION.md) - Resumo da integração
- [`docs/GITHUB_TOKEN_QUICKSTART.md`](docs/GITHUB_TOKEN_QUICKSTART.md) - Setup rápido de token

## ⚙️ Configuração

O arquivo [`config/.aider.conf.yml`](config/.aider.conf.yml) contém as configurações padrão do Aider.

Um symlink é criado na raiz do projeto para compatibilidade.

## 🔗 Symlinks na Raiz

Para facilitar o acesso, os seguintes symlinks são mantidos na raiz do projeto:

- `aider-start.sh` → `ai-support/scripts/aider-start.sh`
- `validate-aider.sh` → `ai-support/scripts/validate-aider.sh`
- `.aider.conf.yml` → `ai-support/config/.aider.conf.yml`

## 💡 Quick Start

```bash
# 1. Validar instalação
./validate-aider.sh

# 2. Configurar token (se necessário)
source ./ai-support/scripts/setup-github-token.sh

# 3. Iniciar Aider
./aider-start.sh

# 4. Com arquivos específicos
./aider-start.sh commons.sh create-vrf.sh
```

## 🔧 Troubleshooting

Se encontrar problemas de autenticação:

```bash
./ai-support/scripts/fix-aider-auth.sh
```

Para mais detalhes, consulte [`docs/AIDER_SETUP.md`](docs/AIDER_SETUP.md).

## 🧪 Teste de Migração

Para validar a estrutura completa do [`ai-support/`](.):

```bash
./test-ai-support-migration.sh
```

Este script verifica:

- ✅ Estrutura de diretórios
- ✅ Existência de todos os arquivos
- ✅ Symlinks funcionando
- ✅ Permissões de execução
- ✅ Validação com shellcheck
- ✅ Validação com markdownlint

## 📚 Mais Informações

- [`MIGRATION.md`](MIGRATION.md) - Detalhes da migração para [`ai-support/`](.)
- [`README.md`](../README.md) - Documentação principal do projeto

---

**Última atualização:** 2025-10-20
