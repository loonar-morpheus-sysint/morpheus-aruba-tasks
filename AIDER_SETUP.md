# Aider — Configuração e Uso (AI Powered)

## Visão Geral

Este DevContainer está configurado para oferecer um fluxo de trabalho AI Powered: Aider (CLI/REPL) para assistênca interativa no terminal, e GitHub Copilot como assistente integrado ao editor. A configuração já disponibiliza variáveis e integrações necessárias para usar ambos de forma segura no container.

## Configuração

### Variáveis de Ambiente

O ambiente está pré-configurado com as seguintes variáveis:

- `OPENAI_API_BASE=https://api.githubcopilot.com` - Endpoint do GitHub Copilot
- `OPENAI_API_KEY=${GITHUB_TOKEN}` - Token OAuth do GitHub (automático)
- `AIDER_MODEL=gpt-4` - Modelo LLM a ser utilizado
  - Dica: com GitHub Copilot, prefira `gpt-4o-mini` para reduzir riscos de estouro de tokens
- `AIDER_AUTO_COMMITS=false` - Desabilita commits automáticos
- `AIDER_DARK_MODE=true` - Habilita modo escuro

### Pré-requisitos

Para usar Aider e Copilot no devcontainer você precisa:

1. **GitHub Copilot ativo** na sua conta GitHub
2. **Token de autenticação do GitHub** (`GITHUB_TOKEN`) configurado no ambiente (o Dev Container já tenta expor `gh` token automaticamente quando possível)

#### Como obter o GITHUB_TOKEN

**Opção 1: Script Automatizado (Recomendado)**

Use o script `setup-github-token.sh` para configurar automaticamente:

```bash
# Executar e configurar o token automaticamente
source ./setup-github-token.sh

# Ou executar e depois usar o token configurado
./setup-github-token.sh
```

O script irá:

- Verificar se o GitHub CLI está instalado e autenticado
- Extrair o token usando `gh auth token` (preferível) ou `gh auth status --show-token`
- Limpar automaticamente caracteres inválidos e quebras de linha
- Configurar a variável `GITHUB_TOKEN` no ambiente atual
- Validar se o token está funcionando corretamente via API do GitHub

**Opção 2: Usar GitHub CLI (Manual)**

```bash
# Autenticar com GitHub CLI
gh auth login

# Ver o token e configurar manualmente
gh auth status --show-token
export GITHUB_TOKEN="seu_token_aqui"
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

### Configuração Rápida

Antes de usar o Aider, configure o token do GitHub:

```bash
# Configurar token automaticamente (recomendado)
source ./setup-github-token.sh

# Verificar se está configurado
echo "Token: ${GITHUB_TOKEN:0:8}...${GITHUB_TOKEN: -4}"

# Testar conectividade com API do GitHub
gh api user --jq '.login'

# Testar se funciona com Aider (se instalado)
aider --model gpt-4o-mini --help
```

### Recursos Avançados do Script

O script `setup-github-token.sh` inclui recursos avançados para máxima compatibilidade:

#### Limpeza Automática de Token

- Remove automaticamente quebras de linha (`\n\r`) e espaços
- Filtra caracteres especiais que podem causar erros de API
- Garante formato válido para cabeçalhos HTTP

#### Métodos de Extração Múltiplos

```bash
# Prioridade 1: gh auth token (mais limpo)
gh auth token

# Fallback: gh auth status --show-token (compatibilidade)
gh auth status --show-token | grep Token
```

#### Validação Robusta

- Testa conectividade real com API do GitHub
- Verifica formato do token (gh[ops]_...)
- Fornece diagnósticos detalhados em caso de erro

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

### Dicas para uso com GitHub Copilot (limite de tokens)

Quando usar o Copilot como backend (`OPENAI_API_BASE=<https://api.githubcopilot.com>`), o limite de tokens por requisição é menor que na OpenAI direta. Você pode ver erros como:

```text
Request body too large for gpt-4o model. Max size: 8000 tokens. (HTTP 413)
```

Boas práticas para evitar estouro de contexto:

- Prefira o modelo `gpt-4o-mini` quando trabalhar com repositórios maiores
- Limite o mapa do repositório e histórico:
  - `--map-tokens 512`
  - `--max-chat-history-tokens 2000`
- Traga menos arquivos por vez (use `/add arquivo.sh` conforme necessário)
- Evite adicionar binários, imagens e grandes blobs

Exemplos:

```bash
# Modelo mais leve e rápido
aider --model gpt-4o-mini

# Com limites mais conservadores
aider --model gpt-4o-mini --map-tokens 512 --max-chat-history-tokens 2000
```

### Configuração otimizada (.aider.conf.yml)

Você pode manter uma configuração padrão otimizada para Copilot no arquivo `.aider.conf.yml` na raiz do repo:

```yaml
model: gpt-4o-mini
auto-commits: false
dark-mode: true
map-tokens: 512
max-chat-history-tokens: 2000
no-show-model-warnings: true
stream: true
pretty: true
```

### Script de conveniência: aider-start.sh

O repositório inclui o script `aider-start.sh` que:

- Configura `GITHUB_TOKEN`, `OPENAI_API_KEY` e `OPENAI_API_BASE` automaticamente (via `setup-github-token.sh`)
- Inicia o Aider com `gpt-4o-mini` e limites recomendados

Como usar:

```bash
# Iniciar vazio
./aider-start.sh

# Iniciar com arquivos
./aider-start.sh AGENTS.md commons.sh
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
# Use o script automatizado (recomendado)
source ./setup-github-token.sh

# Ou verifique manualmente se o token está configurado
echo $GITHUB_TOKEN

# Se estiver vazio, configure manualmente:
export GITHUB_TOKEN=$(gh auth token)

# Ou autentique novamente:
gh auth login
```

**Causa:** GitHub CLI não instalado, não autenticado ou mudança de usuário

**Solução:**

```bash
# Verifique se gh está instalado
which gh

# Se não estiver instalado
sudo apt-get update && sudo apt-get install gh

# Para mudança de usuário, faça logout primeiro
gh auth logout

# Autentique com GitHub
gh auth login

# Execute o script novamente
source ./setup-github-token.sh
```

### Mudança de Conta GitHub

**Processo Completo para Trocar de Usuário:**

```bash
# 1. Logout da conta atual
gh auth logout

# 2. Limpar variáveis antigas
unset GITHUB_TOKEN
unset OPENAI_API_KEY

# 3. Autenticar com nova conta
gh auth login

# 4. Verificar nova autenticação
gh auth status

# 5. Configurar novo token
source ./setup-github-token.sh

# 6. Confirmar nova identidade
gh api user --jq '.login'
```

**Verificação de Identidade:**

```bash
# Verificar usuário atual
echo "Usuário GitHub: $(gh api user --jq '.login')"
echo "Token configurado: ${GITHUB_TOKEN:0:8}...${GITHUB_TOKEN: -4}"
echo "Copilot disponível: $(gh api /user/copilot/settings --jq '.public_code_suggestions')"
```

### Erro: "invalid header field value for Authorization"

**Causa:** Token contém caracteres especiais, quebras de linha ou formatação inválida

**Solução Automática:**

```bash
# Use o script corrigido (resolve automaticamente)
source ./setup-github-token.sh
```

**Solução Manual:**

```bash
# Limpe e reconfigure o token manualmente
gh auth logout
gh auth login

# Ou force limpeza manual do token
export GITHUB_TOKEN=$(gh auth token 2>/dev/null | tr -d '\n\r[:space:]')

# Teste o token limpo
gh api user --jq '.login'
```

### Token funciona no terminal mas falha no Aider

**Causa:** Variáveis de ambiente não propagadas corretamente

**Solução:**

```bash
# Verifique se a variável está configurada
echo "GITHUB_TOKEN length: ${#GITHUB_TOKEN}"

# Se vazia, reconfigure
source ./setup-github-token.sh

# Para persistir entre sessões
echo "export GITHUB_TOKEN=\"${GITHUB_TOKEN}\"" >> ~/.bashrc
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

## Comandos de Diagnóstico

Para debugar problemas de configuração:

```bash
# Status completo do sistema
echo "=== DIAGNÓSTICO AIDER/COPILOT ==="
echo "GitHub CLI: $(gh --version | head -1)"
echo "Usuário: $(gh api user --jq '.login' 2>/dev/null || echo 'Não autenticado')"
echo "Token length: ${#GITHUB_TOKEN}"
echo "Token sample: ${GITHUB_TOKEN:0:8}...${GITHUB_TOKEN: -4}"
echo "API test: $(gh api user --jq '.name' 2>/dev/null || echo 'FALHOU')"
echo "Aider: $(which aider 2>/dev/null || echo 'Não instalado')"
```

## Recursos Adicionais

- **Documentação oficial:** <https://aider.chat/>
- **GitHub Copilot API:** <https://docs.github.com/en/copilot>
- **Padrões do projeto:** Ver `AGENTS.md`
- **Exemplos de scripts:** Ver `commons.sh`, `create-vrf.sh`
- **Script de configuração:** `setup-github-token.sh`

## Suporte

Para problemas específicos do projeto:

1. Verifique `AGENTS.md` para padrões
2. Execute `./run-tests.sh` para validar
3. Consulte `TESTING.md` para testes
4. Veja `CONTRIBUTING.md` para guidelines

---

**Última atualização:** Outubro 2025
