FROM mcr.microsoft.com/devcontainers/base:ubuntu

# Instala dependências do sistema
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends \
    shellcheck \
    python3 \
    python3-pip \
    python3-venv \
    git \
    curl \
    jq \
    yamllint \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*

# Instala Node.js e markdownlint-cli
RUN curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - \
    && apt-get install -y nodejs \
    && npm install -g markdownlint-cli \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*

# Configura usuário não-root
USER vscode

# Instala pre-commit no ambiente do usuário
RUN python3 -m pip install --user --upgrade pip \
    && python3 -m pip install --user pre-commit detect-secrets

# Adiciona binários Python ao PATH
ENV PATH="/home/vscode/.local/bin:${PATH}"
