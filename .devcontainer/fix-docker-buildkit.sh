#!/bin/bash
# Script: fix-docker-buildkit.sh
# Description: Correções para problemas de rede do Docker BuildKit

set -e

echo "=== Correção de Problemas Docker BuildKit ==="
echo

# Solicitar confirmação
read -p "Aplicar correções? Isso vai: limpar cache BuildKit, recriar builder, configurar DNS. [s/N] " -n 1 -r
echo
if [[ ! $REPLY =~ ^[SsYy]$ ]]; then
    echo "Operação cancelada."
    exit 0
fi

# 1. Limpar cache do BuildKit
echo "1. Limpando cache do BuildKit..."
docker buildx prune -af || echo "⚠️ Não foi possível limpar cache"
echo

# 2. Remover builder padrão se existir
echo "2. Removendo builder padrão (se existir)..."
docker buildx rm default 2>/dev/null || echo "Builder 'default' não existe (OK)"
echo

# 3. Criar novo builder com configuração de rede correta
echo "3. Criando novo builder com configuração otimizada..."
docker buildx create --name devcontainer-builder --driver docker-container --bootstrap --use
echo

# 4. Verificar se DNS do Docker está configurado
echo "4. Verificando configuração de DNS do Docker..."
if [ ! -f /etc/docker/daemon.json ]; then
    echo "⚠️ /etc/docker/daemon.json não existe. Criando com DNS do Google..."
    sudo tee /etc/docker/daemon.json > /dev/null << 'EOF'
{
  "dns": ["8.8.8.8", "8.8.4.4"],
  "dns-search": ["."]
}
EOF
    echo "✅ Arquivo /etc/docker/daemon.json criado"
    echo "⚠️ NECESSÁRIO: reiniciar Docker daemon"
    echo "   Execute: sudo systemctl restart docker"
else
    echo "✅ /etc/docker/daemon.json já existe"
    echo "   Conteúdo atual:"
    cat /etc/docker/daemon.json | jq '.'
fi
echo

# 5. Testar novo builder
echo "5. Testando novo builder..."
cat > /tmp/test-dockerfile << 'EOF'
FROM alpine:latest
RUN echo "Teste de conectividade"
EOF
docker buildx build --builder devcontainer-builder --no-cache -f /tmp/test-dockerfile /tmp/ && echo "✅ Builder funcionando!" || echo "❌ Builder ainda com problemas"
echo

echo "=== Correção concluída ==="
echo
echo "PRÓXIMOS PASSOS:"
echo "1. Se o teste acima passou: tente abrir o DevContainer novamente"
echo "2. Se /etc/docker/daemon.json foi criado/modificado: reinicie o Docker"
echo "   sudo systemctl restart docker"
echo "3. Se problemas persistirem: verifique firewall/proxy corporativo"
echo
echo "Para reverter devcontainer.json para usar build (em vez de image):"
echo "  - Edite .devcontainer/devcontainer.json"
echo "  - Troque 'image': 'test-morpheus-aruba:latest' por 'build': {...}"
