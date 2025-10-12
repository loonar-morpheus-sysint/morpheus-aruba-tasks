# Aider — Configuração e Uso (AI Powered)

## Visão Geral

Este DevContainer está configurado para oferecer um fluxo de trabalho AI Powered: Aider (CLI/REPL) para assistênca interativa no terminal, e GitHub Copilot como assistente integrado ao editor. A configuração já disponibiliza variáveis e integrações necessárias para usar ambos de forma segura no container.

## Configuração

### Variáveis de Ambiente

O ambiente está pré-configurado com as seguintes variáveis:

- `OPENAI_API_BASE=https://api.githubcopilot.com` - Endpoint do GitHub Copilot
- `OPENAI_API_KEY=${GITHUB_TOKEN}` - Token OAuth do GitHub (automático)
- `AIDER_MODEL=gpt-4` - Modelo LLM a ser utilizado
- `AIDER_AUTO_COMMITS=false` - Desabilita commits automáticos
- `AIDER_DARK_MODE=true` - Habilita modo escuro

### Pré-requisitos

Para usar Aider e Copilot no devcontainer você precisa:

1. **GitHub Copilot ativo** na sua conta GitHub
2. **Token de autenticação do GitHub** (`GITHUB_TOKEN`) configurado no ambiente (o Dev Container já tenta expor `gh` token automaticamente quando possível)

#### Como obter o GITHUB_TOKEN

**Opção 1: Usar GitHub CLI (Recomendado)**

```bash
# Autenticar com GitHub CLI
gh auth login

# O token será automaticamente disponibilizado
gh auth token
```

**Opção 2: Criar Personal Access Token**

1. Acesse: <https://github.com/settings/tokens>
2. Clique em "Generate new token" → "Generate new token (classic)"
3. Selecione os escopos necessários:
   - `repo` (acesso completo a repositórios)
   - `read:org` (ler informações da organização)
   - `copilot` (se disponível)
4. Copie o token gerado

**Opção 3: Configurar no ambiente local**

Antes de abrir o DevContainer, configure a variável de ambiente no seu sistema:

```bash
# Linux/macOS - Adicione ao ~/.bashrc ou ~/.zshrc
export GITHUB_TOKEN="ghp_seu_token_aqui"

# Windows PowerShell
$env:GITHUB_TOKEN="ghp_seu_token_aqui"
```

## Uso do Aider

### Comandos Básicos

```bash
# Iniciar Aider no diretório atual
aider

# Iniciar com arquivos específicos
aider commons.sh aruba-auth.sh

# Usar modelo específico
aider --model gpt-4

# Modo apenas leitura (não faz alterações)
aider --read-only

# Ver ajuda completa
aider --help
```

### Exemplos de Uso

**Exemplo 1: Criar novo script seguindo padrões**

```bash
# Inicie o Aider com o template e guia de padrões
aider AGENTS.md commons.sh

# No prompt do Aider, digite:
> Crie um novo script chamado 'backup-config.sh' que:
> 1. Siga os padrões do AGENTS.md
> 2. Use commons.sh para logging
> 3. Faça backup de configurações Aruba
> 4. Valide dependências necessárias
```

**Exemplo 2: Refatorar código existente**

```bash
# Abra o script que deseja refatorar
aider create-vrf.sh

# No prompt:
> Refatore este script para:
> 1. Adicionar validação de entrada mais robusta
> 2. Melhorar mensagens de erro
> 3. Adicionar testes unitários BATS
```

**Exemplo 3: Adicionar funcionalidade**

```bash
aider aruba-auth.sh

# No prompt:
> Adicione suporte para autenticação multi-fator (MFA)
> mantendo compatibilidade com código existente
```

### Comandos Interativos do Aider

Dentro do prompt do Aider, você pode usar:

- `/help` - Mostra ajuda completa
- `/add <arquivo>` - Adiciona arquivo ao contexto
- `/drop <arquivo>` - Remove arquivo do contexto
- `/ls` - Lista arquivos no contexto
- `/undo` - Desfaz última alteração
- `/diff` - Mostra diferenças pendentes
- `/commit` - Faz commit das alterações
- `/quit` - Sai do Aider

## Integração com Padrões do Projeto

O Aider está ciente dos padrões do projeto através do arquivo `AGENTS.md`. Para melhores resultados:

1. **Sempre inclua AGENTS.md no contexto:**

   ```bash
   aider AGENTS.md seu-script.sh
   ```

2. **Referencie os padrões nas suas solicitações:**

   ```text
   > Seguindo os padrões do AGENTS.md, crie uma função
   > de validação com logging completo
   ```

3. **Use exemplos existentes como referência:**

   ```bash
   aider AGENTS.md commons.sh create-vrf.sh novo-script.sh
   ```

## Melhores Práticas

### 1. Sempre valide as alterações

```bash
# Após o Aider fazer alterações
shellcheck seu-script.sh
./run-tests.sh
```

### 2. Use commits incrementais

```bash
# Configure auto-commit false para revisar antes
export AIDER_AUTO_COMMITS=false

# Dentro do Aider, revise e commite manualmente
> /diff
> /commit -m "feat: adiciona validação de entrada"
```

### 3. Mantenha contexto focado

```bash
# Evite adicionar muitos arquivos de uma vez
aider arquivo1.sh arquivo2.sh  # ✅ Bom
aider *.sh                      # ❌ Muito amplo
```

### 4. Seja específico nas solicitações

```bash
# ❌ Vago
> Melhore este script

# ✅ Específico
> Adicione validação de parâmetros com mensagens de erro
> claras e códigos de retorno apropriados, seguindo o
> padrão do commons.sh
```

## Solução de Problemas

### Erro: "Authentication failed"

**Causa:** Token do GitHub não configurado ou inválido

**Solução:**

```bash
# Verifique se o token está configurado
echo $GITHUB_TOKEN

# Se estiver vazio, configure:
export GITHUB_TOKEN=$(gh auth token)

# Ou autentique novamente:
gh auth login
```

### Erro: "Model not available"

**Causa:** GitHub Copilot não ativo ou modelo indisponível

**Solução:**

```bash
# Verifique seu plano do Copilot
gh api /user/copilot/settings

# Use modelo alternativo
aider --model gpt-3.5-turbo
```

### Aider não encontrado

**Causa:** Instalação não concluída

**Solução:**

```bash
# Reinstale o Aider
pip3 install --upgrade aider-install

# Verifique a instalação
which aider
aider --version
```

### Performance lenta

**Causa:** Contexto muito grande ou conexão lenta

**Solução:**

```bash
# Reduza o contexto
aider --no-auto-commits --model gpt-3.5-turbo arquivo.sh

# Use modo stream
aider --stream
```

## Recursos Adicionais

- **Documentação oficial:** <https://aider.chat/>
- **GitHub Copilot API:** <https://docs.github.com/en/copilot>
- **Padrões do projeto:** Ver `AGENTS.md`
- **Exemplos de scripts:** Ver `commons.sh`, `create-vrf.sh`

## Suporte

Para problemas específicos do projeto:

1. Verifique `AGENTS.md` para padrões
2. Execute `./run-tests.sh` para validar
3. Consulte `TESTING.md` para testes
4. Veja `CONTRIBUTING.md` para guidelines

---

**Última atualização:** Outubro 2025
