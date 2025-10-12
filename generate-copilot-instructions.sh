#!/bin/bash
################################################################################
# Script: generate-copilot-instructions.sh
# Description: Gera instruções do Copilot a partir do AGENTS.md
################################################################################
#
# DESCRIÇÃO:
#   Lê o arquivo AGENTS.md, traduz o conteúdo para inglês usando a API
#   do Google Translate e gera o arquivo copilot-codegen-instructions.json
#   com instruções para o GitHub Copilot.
#
#   Este script processa o AGENTS.md dinamicamente, permitindo que
#   atualizações no documento sejam automaticamente refletidas nas
#   instruções do Copilot.
#
# DEPENDÊNCIAS:
#   - jq: Para manipulação de JSON
#   - curl: Para chamadas à API de tradução
#
# SAÍDA:
#   - copilot-codegen-instructions.json: Arquivo JSON com instruções em inglês
#
################################################################################

# Verifica se o arquivo AGENTS.md existe
if [ ! -f "AGENTS.md" ]; then
  echo "❌ Erro: AGENTS.md não encontrado."
  exit 1
fi

# Verifica dependências
if ! command -v jq &> /dev/null; then
  echo "❌ Erro: jq não encontrado. Instale com: sudo apt-get install jq"
  exit 1
fi

if ! command -v curl &> /dev/null; then
  echo "❌ Erro: curl não encontrado. Instale com: sudo apt-get install curl"
  exit 1
fi

echo "📝 Lendo conteúdo do AGENTS.md..."

# Lê todo o conteúdo do AGENTS.md
conteudo_completo=$(cat AGENTS.md)

echo "🌍 Traduzindo conteúdo para inglês..."
echo "   (Processando documento em seções principais)"

# Função para traduzir texto usando Google Translate API
traduzir_texto() {
  local texto="$1"

  # Limita tamanho (Google Translate tem limite ~5000 caracteres)
  if [ ${#texto} -gt 4500 ]; then
    echo "TEXTO_MUITO_GRANDE"
    return 1
  fi

  local texto_codificado
  texto_codificado=$(printf '%s' "$texto" | jq -sRr @uri)

  # Chama API do Google Translate
  local resultado
  resultado=$(curl -s "https://translate.googleapis.com/translate_a/single?client=gtx&sl=pt&tl=en&dt=t&q=${texto_codificado}" 2>/dev/null) || return 1

  if [ -z "$resultado" ]; then
    return 1
  fi

  # Extrai texto traduzido
  echo "$resultado" | jq -r '.[0][]?[0]?' 2>/dev/null | grep -v '^null$' | paste -sd ''
}

# Cria diretório temporário para dividir o arquivo
temp_dir=$(mktemp -d)
cd "$temp_dir" || exit 1

# Copia AGENTS.md para o diretório temporário
cp "${OLDPWD}/AGENTS.md" .

# Divide o arquivo em seções (quebra em cada linha que começa com ##)
csplit -s -f section- AGENTS.md '/^## /' '{*}' 2>/dev/null || true

# Retorna ao diretório original
cd "$OLDPWD" || exit 1

# Conta seções
secoes_arquivos=("$temp_dir"/section-*)
total_secoes=${#secoes_arquivos[@]}

echo "   Total de seções detectadas: $total_secoes"

conteudo_traduzido=""
contador=0

for arquivo_secao in "${secoes_arquivos[@]}"; do
  contador=$((contador + 1))

  # Lê conteúdo da seção
  secao_conteudo=$(cat "$arquivo_secao")

  # Pula se vazio
  if [[ -z "${secao_conteudo// /}" ]]; then
    continue
  fi

  tamanho=${#secao_conteudo}
  echo -n "   [$contador/$total_secoes] Traduzindo ($tamanho chars)... "

  # Traduz
  if secao_traduzida=$(traduzir_texto "$secao_conteudo") && [ -n "$secao_traduzida" ] && [ "$secao_traduzida" != "TEXTO_MUITO_GRANDE" ]; then
    conteudo_traduzido="${conteudo_traduzido}${secao_traduzida}

"
    echo "✓"
  else
    if [ "$secao_traduzida" = "TEXTO_MUITO_GRANDE" ]; then
      echo "⚠ (seção muito grande, mantendo original)"
    else
      echo "⚠ (erro na tradução, mantendo original)"
    fi
    conteudo_traduzido="${conteudo_traduzido}${secao_conteudo}

"
  fi

  # Pausa para não sobrecarregar API
  sleep 1
done

# Limpa diretório temporário
rm -rf "$temp_dir"

echo ""

if [ -z "$conteudo_traduzido" ]; then
  echo "❌ Erro: Falha na tradução do conteúdo"
  exit 1
fi

echo "✅ Conteúdo traduzido com sucesso!"
echo "📄 Gerando JSON..."

# Captura a data atual
current_date=$(date -u +%Y-%m-%dT%H:%M:%SZ)

# Cria JSON com jq
if jq -n --arg text "$conteudo_traduzido" --arg date "$current_date" '{
  "version": "1.0",
  "generated": $date,
  "source": "AGENTS.md",
  "instructions": $text
}' > copilot-codegen-instructions.json; then
  echo "✅ Arquivo copilot-codegen-instructions.json criado com sucesso!"
  echo "📊 Estatísticas:"
  echo "   - Tamanho: $(wc -c < copilot-codegen-instructions.json) bytes"
  echo "   - Linhas: $(wc -l < copilot-codegen-instructions.json)"
  echo "   - Caracteres (original PT): ${#conteudo_completo}"
  echo "   - Caracteres (traduzido EN): ${#conteudo_traduzido}"
else
  echo "❌ Erro ao criar o arquivo JSON"
  exit 1
fi

echo ""
echo "📝 Gerando arquivo .github/copilot-instructions.md..."

# Cria diretório .github se não existir
mkdir -p .github

# Gera arquivo Markdown com o conteúdo completo traduzido
cat > .github/copilot-instructions.md << EOF
# GitHub Copilot Instructions for Morpheus Aruba Tasks

> **Auto-Generated**: This file is automatically generated from \`AGENTS.md\` via \`generate-copilot-instructions.sh\`.
> **DO NOT EDIT MANUALLY**: Changes will be overwritten. Edit \`AGENTS.md\` instead.

---

**Last Updated**: ${current_date}
**Source**: AGENTS.md (Portuguese) → Translated to English
**Generator**: generate-copilot-instructions.sh

---

${conteudo_traduzido}

---

> 🔄 **Note**: This file is regenerated whenever \`AGENTS.md\` is modified.
> The file watcher (\`watch-agents.sh\`) automatically updates all instruction files.
EOF

if [ -f .github/copilot-instructions.md ]; then
  echo "✅ Arquivo .github/copilot-instructions.md criado com sucesso!"
  echo "   - Tamanho: $(wc -c < .github/copilot-instructions.md) bytes"
  echo "   - Linhas: $(wc -l < .github/copilot-instructions.md)"
  echo ""
  echo "🎯 GitHub Copilot agora lerá automaticamente as instruções customizadas!"
else
  echo "❌ Erro ao criar o arquivo .github/copilot-instructions.md"
  exit 1
fi
