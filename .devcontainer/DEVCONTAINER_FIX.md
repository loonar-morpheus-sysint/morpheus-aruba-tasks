# DevContainer Fix - Correção de Problemas de Mount

## Problema Resolvido

Corrigido o erro de mount que impedia a abertura do DevContainer:

```text
invalid mount config for type "bind": bind source path does not exist: /.gitconfig
```

## Alterações Realizadas

### 1. devcontainer.json

- **Removidos**: Mounts problemáticos que assumiam existência de arquivos no host
- **Alterado**: `OPENAI_API_KEY` para usar fallback vazio (`${localEnv:GITHUB_TOKEN:-}`)
- **Mantido**: Todas as extensões e configurações VS Code

### 2. post-create.sh

- **Adicionado**: Configuração automática do Git no container
- **Adicionado**: Cópia condicional de arquivos de configuração do host
- **Adicionado**: Configurações adicionais do Git (branch padrão, pull strategy, etc.)
- **Melhorado**: Detecção e configuração de ambiente

### 3. Funcionalidades Mantidas

- ✅ Todas as extensões VS Code
- ✅ Ferramentas de desenvolvimento (shellcheck, markdownlint, etc.)
- ✅ GitHub Copilot integração
- ✅ Aider AI support
- ✅ Python/Node.js development
- ✅ BATS testing
- ✅ AGENTS.md monitoring

## Como Usar Após a Correção

1. **Rebuild Container**:

   ```text
   Ctrl+Shift+P → "Dev Containers: Rebuild Container"
   ```

2. **Primeiro uso**:
   - O Git será configurado automaticamente
   - Defina `GITHUB_TOKEN` no ambiente local para usar GitHub Copilot
   - Execute `./run-tests.sh` para validar o ambiente

3. **Configurar GitHub Token** (opcional):

   ```bash
   # No host (fora do container)
   export GITHUB_TOKEN=$(gh auth token)

   # Ou adicione ao seu .bashrc/.zshrc
   echo 'export GITHUB_TOKEN=$(gh auth token)' >> ~/.bashrc
   ```

## Verificação de Funcionamento

Após abrir o DevContainer, execute:

```bash
# Verificar Git
git config --list --global

# Verificar ferramentas
shellcheck --version
markdownlint --version

# Verificar Aider (se GITHUB_TOKEN estiver configurado)
aider --version

# Executar testes
./run-tests.sh
```

## Troubleshooting

### Se ainda houver problemas

1. **Docker não rodando**:

   ```bash
   sudo service docker start  # Linux
   # Ou abra Docker Desktop no Windows/Mac
   ```

2. **Permissões**:

   ```bash
   sudo usermod -aG docker $USER
   # Reinicie o terminal
   ```

3. **Limpar cache Docker**:

   ```bash
   docker system prune -a  # Remove imagens não utilizadas
   ```

4. **Rebuild completo**:
   - Feche VS Code
   - Delete pasta `.devcontainer` temporariamente
   - Execute `docker system prune -a`
   - Restaure `.devcontainer`
   - Reabra no VS Code

## Status

- ✅ **Resolvido**: Erro de mount bind
- ✅ **Resolvido**: Configuração Git automática
- ✅ **Mantido**: Todas as funcionalidades originais
- ✅ **Melhorado**: Robustez e tratamento de erros

**Data da correção**: 2025-10-14
**Testado em**: WSL2/Ubuntu, Docker Desktop
