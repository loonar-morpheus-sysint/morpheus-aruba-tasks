FROM mcr.microsoft.com/devcontainers/base:ubuntu

# Instala dependências do sistema
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends \
    build-essential \
    software-properties-common \
    shellcheck \
    shfmt \
    git \
    curl \
    wget \
    jq \
    yamllint \
    vim \
    nano \
    zip \
    unzip \
    ca-certificates \
    gnupg \
    lsb-release \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*

# Instala Python 3.12 (última versão estável)
RUN add-apt-repository ppa:deadsnakes/ppa -y \
    && apt-get update \
    && apt-get -y install --no-install-recommends \
    python3.12 \
    python3.12-venv \
    python3.12-dev \
    python3-pip \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*

# Configura Python 3.12 como padrão
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.12 1 \
    && update-alternatives --install /usr/bin/python python /usr/bin/python3.12 1

# Instala Node.js 20.x LTS (última versão LTS)
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*

# Atualiza npm para a última versão
RUN npm install -g npm@latest

# Instala ferramentas globais do Node.js
RUN npm install -g \
    markdownlint-cli \
    markdownlint-cli2 \
    prettier \
    eslint \
    typescript \
    bash-language-server

# Configura usuário não-root
USER vscode

# Atualiza pip para a última versão
RUN python3 -m pip install --user --upgrade pip setuptools wheel

# Instala ferramentas Python de desenvolvimento
RUN python3 -m pip install --user --upgrade \
    pre-commit \
    detect-secrets \
    pylint \
    flake8 \
    black \
    autopep8 \
    mypy \
    bandit \
    safety \
    pytest \
    pytest-cov \
    ipython \
    ansible \
    ansible-lint

# Adiciona binários Python ao PATH
ENV PATH="/home/vscode/.local/bin:${PATH}"

# Configura ambiente bash
RUN echo 'export EDITOR=vim' >> /home/vscode/.bashrc \
    && echo 'alias ll="ls -lah"' >> /home/vscode/.bashrc \
    && echo 'alias python=python3' >> /home/vscode/.bashrc
