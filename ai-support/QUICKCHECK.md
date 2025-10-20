# ⚡ Quick Check - ai-support/

Verificação rápida da estrutura e funcionalidade do diretório ai-support/.

## 📋 Checklist de Validação

### Estrutura

```bash
# Verificar estrutura
tree ai-support/ -L 2
```

Esperado:

```text
ai-support/
├── config/
├── docs/
├── scripts/
├── CHANGELOG.md
├── EXECUTIVE_SUMMARY.md
├── MIGRATION.md
├── QUICKCHECK.md
└── README.md
```

### Symlinks

```bash
# Verificar symlinks
ls -lah | grep "aider\|\.aider"
```

Esperado:

```text
.aider.conf.yml -> ai-support/config/.aider.conf.yml
aider-start.sh -> ai-support/scripts/aider-start.sh
validate-aider.sh -> ai-support/scripts/validate-aider.sh
```

### Permissões

```bash
# Verificar permissões
ls -lh ai-support/scripts/*.sh
```

Todos devem ter `x` (executável).

### Validação de Qualidade

```bash
# Shellcheck
shellcheck ai-support/scripts/*.sh

# Markdownlint
markdownlint ai-support/**/*.md

# Teste completo
./test-ai-support-migration.sh
```

## ✅ Teste Rápido

```bash
# 1. Testar symlink de validação
./validate-aider.sh --help

# 2. Testar symlink do aider-start
./aider-start.sh --help

# 3. Testar script de migração
./test-ai-support-migration.sh

# 4. Verificar config
cat .aider.conf.yml
```

## 📖 Links Rápidos

- [`README.md`](README.md) - Visão geral
- [`MIGRATION.md`](MIGRATION.md) - Detalhes da migração
- [`EXECUTIVE_SUMMARY.md`](EXECUTIVE_SUMMARY.md) - Resumo executivo
- [`CHANGELOG.md`](CHANGELOG.md) - Log de mudanças

## 🆘 Problemas Comuns

### Symlinks quebrados

```bash
# Recriar symlinks
ln -sf ai-support/scripts/aider-start.sh aider-start.sh
ln -sf ai-support/scripts/validate-aider.sh validate-aider.sh
ln -sf ai-support/config/.aider.conf.yml .aider.conf.yml
```

### Scripts não executáveis

```bash
# Corrigir permissões
chmod +x ai-support/scripts/*.sh
```

### Validação falhou

```bash
# Executar teste detalhado
./test-ai-support-migration.sh
```

---

**Última atualização:** 2025-10-20
