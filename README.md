# morpheus-aruba-tasks

## Descrição

Repositório de scripts em Bash para automatização de tarefas administrativas em switches Aruba da HPE. Esses scripts são projetados para serem executados como tarefas no Morpheus Data, permitindo a criação de itens no catálogo de aplicações de autoatendimento.

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
