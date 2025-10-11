# Comandos Rápidos - Testes BATS

## Instalação

```bash
# Ubuntu/Debian
sudo apt-get update && sudo apt-get install -y bats

# macOS
brew install bats-core

# Verificar instalação
bats --version
```

## Executar Testes

```bash
# Todos os testes (recomendado)
./run-tests.sh

# Teste específico
bats tests/test_aruba-auth.bats
bats tests/test_create-vrf.bats
bats tests/test_install-aruba-cli.bats

# Com verbose
bats -t tests/*.bats

# Apenas um teste dentro de um arquivo
bats -f "Script file exists" tests/test_aruba-auth.bats
```

## Pre-commit

```bash
# Executar apenas BATS
pre-commit run bats-tests --all-files

# Executar todos os hooks
pre-commit run --all-files

# Instalar hooks do git
pre-commit install
pre-commit install --hook-type commit-msg

# Atualizar configuração
pre-commit migrate-config
pre-commit autoupdate
```

## Desenvolvimento

```bash
# Criar novo teste
cat > tests/test_meu-script.bats << 'EOF'
#!/usr/bin/env bats

load test_helper

@test "meu-script.sh: Script existe" {
  [ -f "${PROJECT_ROOT}/meu-script.sh" ]
}
EOF

# Tornar executável
chmod +x tests/test_meu-script.bats

# Executar
bats tests/test_meu-script.bats
```

## Debugging

```bash
# Ver output completo
bats -t tests/test_aruba-auth.bats

# Executar apenas testes que falharam
./run-tests.sh | grep "not ok"

# Ver detalhes de uma falha específica
bats tests/test_aruba-auth.bats 2>&1 | grep -A 5 "not ok"
```

## Git Workflow

```bash
# Antes de commitar
./run-tests.sh
pre-commit run --all-files

# Fazer commit (pre-commit executa automaticamente)
git add .
git commit -m "feat: Adiciona novo script"

# Se testes falharem, corrigir e tentar novamente
# O commit será bloqueado até passar

# Forçar commit (NÃO RECOMENDADO)
git commit --no-verify -m "fix: Correção urgente"
```

## Verificar Status

```bash
# Ver resultados dos últimos testes
./run-tests.sh

# Contar testes
grep -c "@test" tests/*.bats

# Ver quais testes estão falhando
bats tests/*.bats 2>&1 | grep "not ok"

# Estatísticas
bats tests/*.bats 2>&1 | tail -n 1
```

## GitHub Actions

```bash
# Ver workflow localmente (com act)
act -l

# Executar workflow localmente
act push

# Ver logs do último workflow
gh run list
gh run view <run-id>
```

## Limpeza

```bash
# Limpar cache do pre-commit
pre-commit clean
pre-commit uninstall

# Remover hooks do git
rm .git/hooks/pre-commit
rm .git/hooks/commit-msg

# Re-instalar
pre-commit install
pre-commit install --hook-type commit-msg
```

## Troubleshooting

```bash
# BATS não encontrado
which bats
command -v bats
sudo apt-get install -y bats

# Pre-commit com erros
pre-commit clean
pre-commit install --install-hooks
pre-commit run --all-files

# Testes não executam
chmod +x tests/*.bats
chmod +x run-tests.sh

# Verificar sintaxe YAML
yamllint .pre-commit-config.yaml
python3 -c "import yaml; yaml.safe_load(open('.pre-commit-config.yaml'))"
```

## Referências Rápidas

- **BATS Docs**: <https://bats-core.readthedocs.io/>
- **Pre-commit**: <https://pre-commit.com/>
- **AGENTS.md**: Padrões do projeto
- **TESTING.md**: Documentação completa
- **tests/README.md**: Guia detalhado BATS
