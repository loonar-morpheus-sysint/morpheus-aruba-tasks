# Guia de Teste - Compartilhamento de Autenticação WSL → DevContainer

## 📋 Pré-requisitos

Na **WSL** (fora do DevContainer), confirme que você tem:

```bash
# 1. GitHub CLI autenticado
gh auth status
# ✅ Deve mostrar: Logged in to github.com as <seu-usuario>

# 2. Diretório de configuração existe
ls -la ~/.config/gh
# ✅ Deve listar arquivos como: hosts.yml, config.yml

# 3. Git configurado
git config --global user.name
git config --global user.email
# ✅ Deve mostrar seu nome e email

# 4. Chaves SSH (opcional, se usar)
ls -la ~/.ssh/
# ✅ Deve listar: id_rsa, id_rsa.pub (ou id_ed25519, etc.)
```

## 🚀 Passos para Testar

### 1. Rebuild do DevContainer

No VS Code:

```text
Ctrl+Shift+P → Dev Containers: Rebuild Container
```

Aguarde a construção (5-10 minutos).

### 2. Validar Montagens

Após o container iniciar, o `post-create.sh` executará automaticamente e mostrará:

```text
🔧 Configurando Git e arquivos de configuração...
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ .gitconfig montado do host
   Nome: Seu Nome
   Email: seu.email@exemplo.com
✅ Configuração GitHub CLI montada do host
✅ GitHub CLI autenticado com sucesso
   ✓ Logged in to github.com account <seu-usuario> (keyring)
   ✓ Git operations protocol: https
   ✓ Token: gho_************************************
✅ Chaves SSH montadas do host
   Chaves disponíveis:
   - id_ed25519.pub
```

### 3. Testar GitHub CLI

No terminal do DevContainer:

```bash
# Verificar autenticação
gh auth status

# Listar seus repositórios
gh repo list

# Ver detalhes deste repositório
gh repo view

# Criar uma issue de teste (opcional)
gh issue list
```

**Resultado esperado**: Todos os comandos funcionam sem pedir autenticação.

### 4. Testar Git

```bash
# Verificar configuração
git config --global user.name
git config --global user.email

# Fazer um commit de teste (não faça push ainda)
echo "# Teste" > test.txt
git add test.txt
git commit -m "test: validar configuração git no devcontainer"

# Verificar autor do commit
git log -1 --pretty=format:"%an <%ae>"

# Desfazer o commit de teste
git reset --soft HEAD~1
rm test.txt
```

**Resultado esperado**: O commit usa seu nome e email da WSL.

### 5. Testar SSH (se aplicável)

```bash
# Verificar chaves montadas
ls -la ~/.ssh/

# Testar conexão SSH com GitHub
ssh -T git@github.com
# Esperado: "Hi <seu-usuario>! You've successfully authenticated..."

# Clonar um repo privado via SSH (se tiver algum)
# git clone git@github.com:seu-usuario/repo-privado.git /tmp/test-clone
```

**Resultado esperado**: SSH funciona sem pedir senha (usa suas chaves da WSL).

## ✅ Checklist de Validação

Após rebuild, confirme:

- [ ] `gh auth status` mostra autenticação ativa
- [ ] `gh repo list` lista seus repositórios
- [ ] `git config --global user.name` mostra seu nome da WSL
- [ ] `git config --global user.email` mostra seu email da WSL
- [ ] `ls ~/.ssh/` lista suas chaves da WSL
- [ ] `ssh -T git@github.com` autentica com sucesso
- [ ] Commits usam automaticamente seu nome/email

## 🐛 Troubleshooting

### Problema: "gh: command not found"

**Causa**: Feature do GitHub CLI não instalada.

**Solução**:

```bash
# Verificar se a feature está no devcontainer.json
cat .devcontainer/devcontainer.json | grep github-cli
```

Deve mostrar:

```jsonc
"ghcr.io/devcontainers/features/github-cli:1": {
```

Se não estiver, adicione e faça rebuild.

### Problema: "gh auth status" retorna "You are not logged in"

**Causa 1**: Diretório `~/.config/gh` não foi montado.

**Verificação**:

```bash
# No container
ls -la ~/.config/gh
# Se vazio ou não existe, o mount falhou
```

**Solução**:

```bash
# Verificar no devcontainer.json se há:
# "source=${localEnv:HOME}${localEnv:USERPROFILE}/.config/gh,target=/home/vscode/.config/gh,type=bind"

# Se estiver correto, rebuild sem cache:
# Ctrl+Shift+P → Dev Containers: Rebuild Container Without Cache
```

**Causa 2**: Você não está autenticado na WSL.

**Solução**:

```bash
# Na WSL (fora do container)
gh auth login
```

Depois, rebuild o container.

### Problema: Git usa nome/email errado

**Causa**: `.gitconfig` não montado ou sobrescrito.

**Verificação**:

```bash
# Verificar se arquivo foi montado
ls -la ~/.gitconfig

# Ver conteúdo
cat ~/.gitconfig | grep -A2 "\[user\]"
```

**Solução**:

```bash
# Se estiver vazio, configure manualmente:
git config --global user.name "Seu Nome"
git config --global user.email "seu.email@exemplo.com"

# Ou corrija na WSL e faça rebuild
```

### Problema: SSH não funciona

**Causa 1**: Chaves não montadas.

**Verificação**:

```bash
ls -la ~/.ssh/
# Deve mostrar suas chaves da WSL
```

**Solução**: Rebuild do container.

**Causa 2**: Permissões incorretas.

**Verificação**:

```bash
ls -l ~/.ssh/id_*
# Chave privada deve ter permissões 600 ou 400
```

**Solução**:

```bash
# No container, não é possível alterar (readonly mount)
# Corrija na WSL:
chmod 600 ~/.ssh/id_rsa
chmod 644 ~/.ssh/id_rsa.pub
```

Depois, rebuild.

### Problema: "Permission denied (publickey)"

**Causa**: Chave SSH não adicionada ao ssh-agent ou não configurada no GitHub.

**Solução**:

```bash
# Na WSL, verificar se a chave está no GitHub:
gh ssh-key list

# Se não estiver, adicionar:
gh ssh-key add ~/.ssh/id_ed25519.pub --title "WSL"

# Ou via navegador:
# https://github.com/settings/keys
```

## 📊 Comparação: Antes vs Depois

### Antes (sem mounts)

```bash
# No DevContainer
gh auth status
# ❌ You are not logged in to any GitHub hosts

gh auth login
# 😞 Precisa autenticar manualmente toda vez que rebuilda
```

### Depois (com mounts)

```bash
# No DevContainer
gh auth status
# ✅ Logged in to github.com as <seu-usuario> (keyring)

gh repo list
# ✅ Funciona imediatamente, sem autenticação adicional
```

## 🎯 Benefícios

1. **Zero configuração**: Abre o DevContainer e já está autenticado
2. **Sincronização automática**: Mudanças na autenticação da WSL refletem no container
3. **Segurança**: Chaves SSH montadas como somente leitura
4. **Produtividade**: Não precisa re-autenticar a cada rebuild

## 📚 Referências

- [DevContainers - Sharing git credentials](https://code.visualstudio.com/remote/advancedcontainers/sharing-git-credentials)
- [GitHub CLI Manual](https://cli.github.com/manual/)
- [Git Configuration](https://git-scm.com/book/en/v2/Customizing-Git-Git-Configuration)

## 💡 Próximos Passos

Após validar a autenticação:

1. ✅ Teste criar uma branch
2. ✅ Teste fazer commit
3. ✅ Teste push para GitHub
4. ✅ Teste criar PR via `gh pr create`
5. ✅ Teste usar Aider AI (se GITHUB_TOKEN estiver configurado)

---

**Status**: 🟢 Pronto para produção
**Última atualização**: 2025-10-20
**Mantido por**: Equipe Morpheus Aruba Tasks
