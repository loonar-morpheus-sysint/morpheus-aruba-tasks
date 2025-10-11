# morpheus-aruba-tasks

> **⚠️ WIP - Work in Progress**  
> Este projeto está em desenvolvimento ativo. Funcionalidades e documentação podem sofrer alterações.

![LoonarBR cover](./_assets/loonarbr_cover.jpeg)

## Descrição

Repositório de scripts em Bash para automatização de tarefas administrativas em switches Aruba da HPE. Esses scripts são projetados para serem executados como tarefas no Morpheus Data, permitindo a criação de itens no catálogo de aplicações de autoatendimento.

## 🚀 Início Rápido com Dev Container

### Pré-requisitos

- Docker instalado
- Visual Studio Code com extensão "Dev Containers"
- WSL2 configurado (para Windows)
- Git e GitHub CLI configurados no WSL

### Abrindo o Projeto

1. Clone o repositório:

```bash
git clone https://github.com/loonar-morpheus-sysint/morpheus-aruba-tasks.git
cd morpheus-aruba-tasks
```

2. Abra no VS Code:

```bash
code .
```

3. Quando solicitado, clique em "Reopen in Container" ou use o comando:
   - `Ctrl+Shift+P` → "Dev Containers: Reopen in Container"

O container será construído automaticamente com todas as ferramentas instaladas.

## ✅ Validações Automáticas

### Pre-commit Hooks

O projeto utiliza pre-commit para validações automáticas antes de cada commit:

- **Shellcheck**: Valida scripts Bash
- **Markdownlint**: Valida formatação de Markdown
- **YAML Lint**: Valida arquivos YAML
- **JSON Validator**: Valida sintaxe JSON
- **Detect Secrets**: Detecta credenciais e informações sensíveis
- **Commit Messages**: Valida mensagens de commit semânticas (Conventional Commits)
- **Formatação**: Remove espaços em branco, adiciona quebra de linha final

### Executando Validações Manualmente

```bash
# Validar todos os arquivos
pre-commit run --all-files

# Validar apenas arquivos modificados
pre-commit run

# Validar script específico
shellcheck seu-script.sh

# Validar Markdown específico
markdownlint seu-arquivo.md
```

### GitHub Actions

Todas as validações são executadas automaticamente no GitHub Actions para:

- Push na branch `main`
- Push na branch `develop`
- Pull requests para `main` ou `develop`

**Proteção**: Merges para `main` são bloqueados se as validações falharem.

## 🛠️ Ferramentas Instaladas no Dev Container

### Extensões VS Code

- **Shellcheck**: Linting para Bash
- **Bash Debug**: Debugging de scripts Bash
- **Markdownlint**: Linting para Markdown
- **GitHub Copilot**: Assistente de código IA
- **GitHub Copilot Chat**: Chat com IA
- **GitHub Actions**: Suporte para workflows
- **YAML**: Suporte para YAML

### CLI Tools

- `shellcheck`: Validador de scripts Shell
- `markdownlint`: Validador de Markdown
- `yamllint`: Validador de YAML
- `detect-secrets`: Detector de segredos
- `pre-commit`: Framework de hooks Git
- `gh`: GitHub CLI (com autenticação do WSL)

## 📋 Padrões de Código

Consulte [AGENTS.md](./AGENTS.md) para diretrizes completas de desenvolvimento.

Consulte [COMMIT_CONVENTION.md](./COMMIT_CONVENTION.md) para padrões de mensagens de commit.

**Checklist antes de commit**:

- [ ] Todos os scripts `.sh` passam no shellcheck
- [ ] Todos os arquivos `.md` passam no markdownlint
- [ ] Nenhuma credencial está sendo commitada
- [ ] Mensagem de commit segue padrão semântico (feat:, fix:, docs:, etc.)
- [ ] Documentação atualizada

## 🔒 Segurança

Consulte [SECURITY.md](./SECURITY.md) para práticas de segurança e qualidade de código.

## Por que CLI em vez de API?

Este repositório utiliza a CLI (Command Line Interface) da solução Aruba para acesso e manipulação dos switches. A escolha da CLI em vez da API REST foi feita pelos seguintes motivos:

- **Simplicidade**: A CLI é mais direta e integrada naturalmente em scripts Bash, sem necessidade de bibliotecas ou ferramentas adicionais
- **Facilidade de integração**: Scripts Bash podem executar comandos CLI de forma nativa usando SSH, simplificando o fluxo de trabalho
- **Menor complexidade**: Não requer parsing de JSON, manipulação de tokens de autenticação OAuth, ou gerenciamento de dependências externas como `curl` ou `jq`
- **Debugging simplificado**: Comandos CLI são mais fáceis de testar e depurar interativamente

Por outro lado, as APIs REST da Aruba exigem:

- Autenticação mais complexa (tokens, sessões)
- Parsing e manipulação de dados JSON
- Tratamento de códigos de status HTTP
- Dependências externas para processar respostas

Para cenários de automação simples e diretos em Bash, a CLI oferece uma solução mais pragmática e de fácil manutenção.

## Referências

### Documentação Oficial

- **CLI Aruba HPE (ArubaOS-CX)**: [HPE Aruba Networking Command Line Interface Reference](https://www.arubanetworks.com/techdocs/AOS-CX/10.13/HTML/cli_reference/)
- **API REST Aruba HPE**: [HPE Aruba Networking REST API Guide](https://www.arubanetworks.com/techdocs/AOS-CX/10.13/HTML/rest_api_guide/)
- **Página de Marketing Aruba HPE**: [HPE Aruba Networking Solutions](https://www.arubanetworks.com/products/switches/)

---

**Nota**: Este repositório é mantido para uso com o Morpheus Data e está em desenvolvimento contínuo.
