# Guia de Mensagens de Commit Semânticas

Este repositório utiliza o padrão **Conventional Commits** para mensagens de commit. Todas as mensagens de commit são validadas automaticamente pelo pre-commit hook.

## 📋 Formato Obrigatório

```text
<tipo>[escopo opcional]: <descrição>

[corpo opcional]

[rodapé(s) opcional(is)]
```

## 🎯 Tipos Permitidos

### Tipos Principais

| Tipo | Descrição | Exemplo |
|------|-----------|---------|
| `feat` | Nova funcionalidade | `feat: adicionar autenticação Aruba` |
| `fix` | Correção de bug | `fix: corrigir validação de VRF` |
| `docs` | Apenas documentação | `docs: atualizar README com exemplos` |
| `style` | Formatação (sem mudança de lógica) | `style: formatar código com shellcheck` |
| `refactor` | Refatoração de código | `refactor: reorganizar funções comuns` |
| `perf` | Melhoria de performance | `perf: otimizar loop de validação` |
| `test` | Adição/correção de testes | `test: adicionar testes para create-vrf` |

### Tipos Auxiliares

| Tipo | Descrição | Exemplo |
|------|-----------|---------|
| `chore` | Tarefas, dependências, config | `chore: atualizar pre-commit hooks` |
| `ci` | Mudanças em CI/CD | `ci: adicionar validação no GitHub Actions` |
| `build` | Sistema de build | `build: atualizar Dockerfile` |
| `revert` | Reverter commit anterior | `revert: desfazer feat de autenticação` |

## ✅ Exemplos Válidos

### Commit Simples

```bash
git commit -m "feat: adicionar script de criação de VLAN"
```

### Commit com Escopo

```bash
git commit -m "fix(auth): corrigir timeout na autenticação"
```

### Commit com Corpo

```bash
git commit -m "feat: implementar validação de credenciais

- Adicionar verificação de ARUBA_HOST
- Validar formato de credenciais
- Implementar retry em caso de falha"
```

### Commit com Breaking Change

```bash
git commit -m "feat!: mudar formato de configuração

BREAKING CHANGE: O arquivo .env agora usa formato YAML
Os usuários devem migrar suas configurações."
```

### Commit com Rodapé

```bash
git commit -m "fix: corrigir bug na criação de VRF

Closes #123
Refs: APM-5230"
```

## ❌ Exemplos Inválidos

```bash
# ❌ Sem tipo
git commit -m "adicionar nova funcionalidade"

# ❌ Tipo inválido
git commit -m "feature: nova funcionalidade"

# ❌ Tipo em maiúscula
git commit -m "FEAT: nova funcionalidade"

# ❌ Descrição vazia
git commit -m "feat:"

# ❌ Ponto final na descrição
git commit -m "feat: nova funcionalidade."

# ❌ Mensagem muito longa (> 100 caracteres)
git commit -m "feat: esta é uma mensagem extremamente longa que ultrapassa o limite de cem caracteres permitidos"
```

## 🔧 Regras de Validação

### Obrigatórias (Erro - Bloqueia Commit)

- ✅ Tipo deve estar na lista permitida
- ✅ Tipo deve estar em minúsculas
- ✅ Tipo não pode estar vazio
- ✅ Descrição não pode estar vazia
- ✅ Descrição não pode terminar com ponto
- ✅ Cabeçalho deve ter no máximo 100 caracteres

### Recomendadas (Warning - Não Bloqueia)

- ⚠️ Corpo deve ter linha em branco após o cabeçalho
- ⚠️ Rodapé deve ter linha em branco antes dele

## 📝 Estrutura Detalhada

### Cabeçalho (Obrigatório)

```text
<tipo>[escopo opcional]: <descrição>
```

**Componentes**:
- **tipo**: Um dos tipos permitidos (feat, fix, docs, etc.)
- **escopo**: (Opcional) Contexto da mudança entre parênteses
- **!**: (Opcional) Indica breaking change
- **descrição**: Descrição concisa da mudança

**Exemplos**:
```text
feat: adicionar validação de entrada
feat(auth): implementar OAuth
feat!: mudar API de autenticação
```

### Corpo (Opcional)

Explicação detalhada da mudança:

```text
- Razão da mudança
- Contexto adicional
- Detalhes de implementação
```

### Rodapé (Opcional)

Metadados adicionais:

```text
BREAKING CHANGE: Descrição da mudança incompatível
Closes #123
Refs: APM-5230
Co-authored-by: Nome <email@example.com>
```

## 🚀 Uso no Dia a Dia

### Commit Rápido (Funcionalidade)

```bash
git commit -m "feat: adicionar logging em create-vrf.sh"
```

### Commit Rápido (Correção)

```bash
git commit -m "fix: corrigir verificação de variável vazia"
```

### Commit Detalhado

```bash
git commit -m "feat(auth): implementar retry automático

- Adicionar retry em caso de timeout
- Configurar delay exponencial
- Limitar a 3 tentativas

Refs: APM-5230"
```

### Commit de Documentação

```bash
git commit -m "docs: adicionar exemplos de uso no README"
```

### Commit de Configuração

```bash
git commit -m "chore: atualizar pre-commit hooks para v4.5.0"
```

## 🛠️ Ferramentas

### Pre-commit Hook

O hook valida automaticamente antes do commit:

```bash
# Instalado automaticamente no dev container
pre-commit install --hook-type commit-msg

# Testar manualmente
echo "feat: test" | pre-commit run conventional-pre-commit --hook-stage commit-msg
```

### Bypass (Não Recomendado)

```bash
# Pular validação (use apenas em emergências)
git commit --no-verify -m "mensagem não semântica"
```

## 📚 Referências

- [Conventional Commits](https://www.conventionalcommits.org/)
- [Semantic Versioning](https://semver.org/)
- [Angular Commit Guidelines](https://github.com/angular/angular/blob/main/CONTRIBUTING.md#commit)

## 💡 Dicas

1. **Seja conciso**: Mensagens curtas e diretas
2. **Use imperativo**: "adicionar" não "adicionado" ou "adicionando"
3. **Capitalize corretamente**: Tipo em minúscula, descrição em minúscula
4. **Sem ponto final**: Não termine a descrição com "."
5. **Um commit, uma mudança**: Cada commit deve representar uma mudança lógica
6. **Use escopo**: Ajuda a entender o contexto (`auth`, `vrf`, `cli`)

## ❓ FAQ

### Qual tipo usar para mudanças na documentação?

Use `docs:` para mudanças exclusivas em documentação.

```bash
git commit -m "docs: atualizar guia de instalação"
```

### Como indicar breaking changes?

Use `!` após o tipo ou adicione `BREAKING CHANGE:` no rodapé:

```bash
git commit -m "feat!: mudar formato de configuração"

# ou

git commit -m "feat: mudar formato de configuração

BREAKING CHANGE: Formato .env alterado para YAML"
```

### Posso combinar múltiplos tipos?

Não. Cada commit deve ter apenas um tipo. Se precisar de múltiplos tipos, faça múltiplos commits.

```bash
# ❌ Errado
git commit -m "feat/fix: adicionar feature e corrigir bug"

# ✅ Correto
git commit -m "feat: adicionar nova feature"
git commit -m "fix: corrigir bug relacionado"
```

### O que fazer se minha mensagem foi rejeitada?

1. Verifique o erro reportado pelo pre-commit
2. Corrija a mensagem seguindo o padrão
3. Tente novamente

```bash
# Se o commit foi rejeitado, use --amend
git commit --amend -m "feat: mensagem corrigida"
```

---

**Validação Automática**: Este padrão é aplicado automaticamente via pre-commit hook.

**Última Atualização**: 2025-10-11
