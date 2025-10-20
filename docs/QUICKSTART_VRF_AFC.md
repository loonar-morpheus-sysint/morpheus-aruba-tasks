# Guia Rápido - Criação de VRF no Fabric Composer

## 📋 Configuração Inicial

### 1. Arquivo `.env` já está configurado com

```bash
FABRIC_COMPOSER_IP=172.31.8.99
FABRIC_COMPOSER_USERNAME=admin
FABRIC_COMPOSER_PASSWORD=Aruba123!
FABRIC_COMPOSER_PORT=443
FABRIC_COMPOSER_PROTOCOL=https
```

### 2. Verificar conectividade com o Fabric Composer

```bash
# Testar conexão (deve retornar 200 ou 401)
curl -k -I https://172.31.8.99/
```

## 🚀 Uso do Script

### Modo 1: Dry-Run (Testar sem criar)

```bash
./scripts/hybrid/create-aruba-vrf.sh \
  --env-file .env \
  --name TESTE-VRF \
  --fabric default \
  --rd 65000:100 \
  --rt-import "65000:100" \
  --rt-export "65000:100" \
  --af ipv4 \
  --description "VRF de Teste" \
  --dry-run
```

### Modo 2: Criar VRF Real

```bash
./scripts/hybrid/create-aruba-vrf.sh \
  --env-file .env \
  --name PROD-VRF \
  --fabric default \
  --rd 65000:100 \
  --rt-import "65000:100" \
  --rt-export "65000:100" \
  --af ipv4 \
  --description "VRF de Produção"
```

### Modo 3: Interativo (Solicita entrada do usuário)

```bash
./scripts/hybrid/create-aruba-vrf.sh --interactive
```

## 🔧 Parâmetros Disponíveis

| Parâmetro | Descrição | Obrigatório | Exemplo |
|-----------|-----------|-------------|---------|
| `--name` | Nome da VRF | ✅ Sim | `PROD-VRF` |
| `--fabric` | Nome do Fabric | ✅ Sim | `default` ou `dc1-fabric` |
| `--rd` | Route Distinguisher | ⚪ Opcional | `65000:100` |
| `--rt-import` | Route Target Import | ⚪ Opcional | `65000:100` ou `65000:100,65000:200` |
| `--rt-export` | Route Target Export | ⚪ Opcional | `65000:100` |
| `--af` | Address Family | ⚪ Opcional | `ipv4`, `ipv6`, ou `ipv4,ipv6` |
| `--description` | Descrição da VRF | ⚪ Opcional | `"VRF de Produção"` |
| `--dry-run` | Validar sem criar | ⚪ Opcional | - |
| `--env-file` | Arquivo de ambiente | ⚪ Opcional | `.env` |

## 📝 Fluxo de Execução

O script executa os seguintes passos:

1. ✅ **Validação de Dependências** (curl, jq, date)
2. ✅ **Carregamento de Variáveis** (.env)
3. ✅ **Validação de Parâmetros** (nome, fabric, RD, etc.)
4. ✅ **Obtenção de Token** (autenticação no Fabric Composer)
5. ✅ **Criação da VRF** (POST `/api/v1/sites/default/vrfs`)
6. ✅ **Aplicação da VRF** (POST `/api/v1/sites/default/vrfs/{UUID}/apply`) ⭐ **NOVO!**

## 🎯 Exemplos Práticos

### Exemplo 1: VRF Simples

```bash
./scripts/hybrid/create-aruba-vrf.sh \
  --env-file .env \
  --name GUEST-VRF \
  --fabric default \
  --description "VRF para rede de convidados"
```

### Exemplo 2: VRF com Route Target

```bash
./scripts/hybrid/create-aruba-vrf.sh \
  --env-file .env \
  --name PROD-VRF \
  --fabric default \
  --rd 65000:100 \
  --rt-import "65000:100,65000:200" \
  --rt-export "65000:100" \
  --description "VRF de Produção com RT"
```

### Exemplo 3: VRF Dual-Stack (IPv4 + IPv6)

```bash
./scripts/hybrid/create-aruba-vrf.sh \
  --env-file .env \
  --name DUALSTACK-VRF \
  --fabric default \
  --rd 65000:300 \
  --rt-import "65000:300" \
  --rt-export "65000:300" \
  --af "ipv4,ipv6" \
  --description "VRF Dual-Stack IPv4/IPv6"
```

## 🧪 Testar com Script de Teste

Use o script de teste fornecido:

```bash
./test-vrf-creation.sh
```

## 📊 Logs e Debug

### Ver logs com mais detalhes

O script usa a biblioteca `commons.sh` com logging estruturado. Para ver logs de debug:

```bash
# Temporariamente ativar debug no commons.sh
LOG_VIEW=debug,info,notice,warn,err,crit,alert,emerg ./scripts/hybrid/create-aruba-vrf.sh --help
```

### Verificar tokens de autenticação

```bash
# Ver token atual (se existir)
cat .afc_token

# Ver quando o token expira
cat .afc_token_expiry
date -d @$(cat .afc_token_expiry)
```

## ❗ Troubleshooting

### Erro: "Authentication failed"

```bash
# Verificar credenciais no .env
cat .env

# Testar autenticação manualmente
curl -k -X POST "https://172.31.8.99/api/v1/auth/token" \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"Aruba123!"}'  # pragma: allowlist secret
```

### Erro: "VRF creation failed"

```bash
# Verificar se o fabric existe
curl -k -X GET "https://172.31.8.99/api/v1/fabrics" \
  -H "Authorization: Bearer $(cat .afc_token)"

# Verificar VRFs existentes
curl -k -X GET "https://172.31.8.99/api/v1/sites/default/vrfs" \
  -H "Authorization: Bearer $(cat .afc_token)"
```

### Erro: "Apply VRF failed"

```bash
# Verificar UUID da VRF (deve estar nos logs)
# O apply step pode falhar se a VRF já foi aplicada anteriormente
# Neste caso, o erro pode ser ignorado
```

## 🔒 Segurança

- ⚠️ O arquivo `.env` contém credenciais sensíveis
- ✅ Arquivo `.env` está no `.gitignore` (não será commitado)
- ✅ Use `.env.example` como template (sem credenciais reais)

## 📚 Referências

- [AFC API Getting Started](https://developer.arubanetworks.com/afc/docs/getting-started-with-the-afc-api)
- [VRF Documentation](https://arubanetworking.hpe.com/techdocs/AFC/700/Content/afc70olh/add-vrf.htm)
- [Ansible Collection](https://github.com/aruba/hpeanfc-ansible-collection)

## ✨ Novidades

### ⭐ Versão Atualizada (Outubro 2025)

- ✅ **Passo de Apply**: Agora o script aplica automaticamente a VRF após criação
- ✅ **Endpoint Correto**: Usa `/api/v1/sites/default/vrfs` (endpoint correto do AFC)
- ✅ **Captura de UUID**: Extrai UUID da resposta para uso no apply step
- ✅ **Tratamento de Erros**: Melhor handling de erros no apply step
- ✅ **Dry-run Skip**: Apply step é pulado em modo dry-run
- ✅ **Configuração .env**: Arquivo .env pré-configurado com suas credenciais

---

**Dúvidas?** Consulte a documentação completa em `docs/CREATE_ARUBA_VRF.md`
