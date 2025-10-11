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

# Instala Python e pipx (gerenciador de ferramentas Python isoladas)
RUN apt-get update \
    && apt-get -y install --no-install-recommends \
    python3 \
    python3-full \
    python3-venv \
    python3-dev \
    python3-pip \
    pipx \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*

# Configura Python como padrão
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3 1

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


# Cria um virtualenv no sistema para ferramentas de desenvolvimento Python
# Instalamos como root dentro de /opt/venv para evitar PEP 668 (externally-managed-environment)
RUN python3 -m venv /opt/venv \
    && /opt/venv/bin/python -m pip install --upgrade pip setuptools wheel \
    && /opt/venv/bin/pip install \
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
        ansible-lint \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*

# Exponha os binários do virtualenv no PATH para todos os usuários
ENV PATH="/opt/venv/bin:/home/vscode/.local/bin:${PATH}"

# Configura usuário não-root
USER vscode

# Configura ambiente bash
RUN echo 'export EDITOR=vim' >> /home/vscode/.bashrc \
    && echo 'alias ll="ls -lah"' >> /home/vscode/.bashrc \
    && echo 'alias python=python3' >> /home/vscode/.bashrc
