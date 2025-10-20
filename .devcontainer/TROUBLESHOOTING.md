# Troubleshooting: DevContainer Build Failures

## Problema: Build Falha com "503 Service Unavailable" no Docker Hub

### Sintomas

- DevContainer falha ao abrir com erro: `ERROR: failed to fetch anonymous token: unexpected status from GET request to https://auth.docker.io/token?scope=repository%3Adocker%2Fdockerfile%3Apull&service=registry.docker.io: 503 Service Unavailable`
- A linha `# syntax=docker/dockerfile:1.4` causa o erro
- Navegador consegue acessar a URL do token normalmente
- Containers normais funcionam, apenas DevContainer com features falha

### Causa Raiz

**Cache corrompido do Docker BuildKit**

Quando o DevContainers CLI adiciona features ao DevContainer, ele:

1. Cria um Dockerfile temporário com `# syntax=docker/dockerfile:1.4`
2. Esta linha instrui o BuildKit a baixar o frontend `docker/dockerfile:1.4` do Docker Hub
3. Se o cache do BuildKit estiver corrompido, ele falha ao buscar o frontend mesmo quando o Docker Hub está funcionando

### Diagnóstico

Execute o script de diagnóstico:

```bash
bash .devcontainer/troubleshoot-docker-network.sh
```

Saída esperada quando o problema é cache corrompido:

- ✅ DNS funcionando (nslookup auth.docker.io resolve)
- ✅ HTTP funcionando (wget consegue baixar token)
- ✅ Build simples OK (sem `# syntax=` funciona)
- ❌ Build com `# syntax=docker/dockerfile:1.4` falha com 503

### Solução

1. **Limpar cache do BuildKit:**

   ```bash
   docker buildx prune -af
   ```

2. **Remover builders problemáticos (se existirem):**

   ```bash
   docker buildx ls  # Listar builders
   docker buildx rm <builder-name>  # Remover builder com erro
   ```

3. **Testar se corrigiu:**

   ```bash
   cat > /tmp/test-syntax.dockerfile << 'EOF'
   # syntax=docker/dockerfile:1.4
   FROM alpine:latest
   RUN echo "Teste"
   EOF
   docker buildx build -f /tmp/test-syntax.dockerfile /tmp/
   ```

4. **Reabrir DevContainer:**
   - VS Code: `Ctrl+Shift+P` → "Dev Containers: Rebuild Container"
   - Ou: `Ctrl+Shift+P` → "Dev Containers: Reopen in Container"

### Solução Alternativa (Workaround Temporário)

Se limpar o cache não resolver (raro), use uma imagem local:

1. Construa a imagem localmente SEM features:

   ```bash
   cd .devcontainer
   docker build -t test-morpheus-aruba:latest .
   ```

2. Edite `devcontainer.json`:

   ```jsonc
   {
     "image": "test-morpheus-aruba:latest",
     // Remova ou comente: "build": { ... }
     // ⚠️ Features NÃO serão instaladas neste modo!
   }
   ```

3. Reabra o DevContainer.

**Limitação:** Ao usar `"image"` em vez de `"build"`, as features do `devcontainer.json` **não são instaladas**. Você precisará instalá-las manualmente no Dockerfile.

### Prevenção

- Limpe o cache do BuildKit periodicamente:

  ```bash
  # Incluir no script de manutenção
  docker buildx prune -f --filter "until=168h"  # Limpa cache > 7 dias
  ```

- Configure GC Policy no BuildKit para limpar cache automaticamente

### Verificação Pós-Correção

Após reabrir o DevContainer, verifique se as features foram instaladas:

```bash
# Dentro do DevContainer
gh --version          # GitHub CLI
git --version         # Git atualizado via PPA
docker --version      # Docker-in-Docker
python3 --version     # Python 3.11
```

### Referências

- [Docker BuildKit Documentation](https://docs.docker.com/build/buildkit/)
- [Dev Containers Features](https://containers.dev/features)
- Issue relacionada: DevContainers CLI adiciona `# syntax=` automaticamente quando usa features
