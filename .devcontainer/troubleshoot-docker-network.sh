#!/bin/bash
# Script: troubleshoot-docker-network.sh
# Description: Diagnóstico e correção de problemas de rede do Docker BuildKit

set -e

echo "=== Diagnóstico de Conectividade Docker BuildKit ==="
echo

# 1. Testar DNS do Docker daemon
echo "1. Testando DNS do Docker daemon..."
docker run --rm alpine sh -c "nslookup auth.docker.io" || echo "❌ DNS falhou"
echo

# 2. Testar conectividade HTTP do Docker
echo "2. Testando conectividade HTTP do Docker..."
docker run --rm alpine sh -c "wget -O- --timeout=5 https://auth.docker.io/token?scope=repository%3Adocker%2Fdockerfile%3Apull\&service=registry.docker.io" || echo "❌ HTTP falhou"
echo

# 3. Verificar configuração do Docker daemon
echo "3. Configuração DNS do Docker daemon:"
if [ -f /etc/docker/daemon.json ]; then
    cat /etc/docker/daemon.json | jq '.dns // "Nenhum DNS configurado"'
else
    echo "Arquivo /etc/docker/daemon.json não existe"
fi
echo

# 4. Verificar builders do buildx
echo "4. Builders do buildx disponíveis:"
docker buildx ls
echo

# 5. Inspecionar builder padrão
echo "5. Configuração do builder atual:"
docker buildx inspect --bootstrap
echo

# 6. Testar build simples sem frontend
echo "6. Testando build simples (sem frontend syntax)..."
cat > /tmp/test-dockerfile << 'EOF'
FROM alpine:latest
RUN echo "Teste de conectividade"
EOF
docker buildx build --no-cache -f /tmp/test-dockerfile /tmp/ && echo "✅ Build simples OK" || echo "❌ Build simples falhou"
echo

echo "=== Diagnóstico concluído ==="
echo
echo "SOLUÇÕES RECOMENDADAS:"
echo "1. Se DNS falhou: configurar DNS no /etc/docker/daemon.json"
echo "2. Se HTTP falhou: verificar proxy ou firewall"
echo "3. Se builder tem problemas: recriar builder com script de correção"
echo
echo "Execute: bash .devcontainer/fix-docker-buildkit.sh"
