FROM ubuntu:26.04

LABEL devcontainer.metadata='[{"remoteUser":"vscode","customizations":{"vscode":{"settings":{"terminal.integrated.defaultProfile.linux":"bash"}}}}]'

ENV DEBIAN_FRONTEND=noninteractive

RUN usermod -l vscode -d /home/vscode -m ubuntu && \
    groupmod -n vscode ubuntu && \
    chsh -s /bin/bash vscode && \
    chsh -s /bin/bash root && \
    apt-get update && apt-get install -y --no-install-recommends \
        sudo \
        locales \
        ca-certificates \
        curl \
        wget \
        git \
        procps \
        unzip \
        tar \
        openssh-client \
        build-essential \
        make \
        gawk \
    && echo "vscode ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/vscode \
    && chmod 0440 /etc/sudoers.d/vscode \
    && echo "en_US.UTF-8 UTF-8" > /etc/locale.gen \
    && locale-gen en_US.UTF-8 \
    && rm -rf /var/lib/apt/lists/*

ENV USER=vscode \
    LOGNAME=vscode \
    LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8 \
    SHELL=/bin/bash \
    PATH="/home/vscode/.local/bin:/home/vscode/.local/share/mise/shims:$PATH"

USER vscode
WORKDIR /home/vscode

RUN git clone --recursive --depth 1 --shallow-submodules https://github.com/akinomyoga/ble.sh.git && \
    make -C ble.sh install PREFIX=/home/vscode/.local && \
    rm -rf ble.sh

RUN curl -fsSL https://mise.run | sh

RUN mkdir -p /home/vscode/.config/mise
COPY --chown=vscode:vscode mise/config.toml /home/vscode/.config/mise/config.toml

RUN mise trust /home/vscode/.config/mise/config.toml && \
    mise install && \
    mise cache clear && \
    rm -rf /home/vscode/.local/share/mise/downloads

RUN git clone https://github.com/LazyVim/starter /home/vscode/.config/nvim && \
    rm -rf /home/vscode/.config/nvim/.git

RUN mkdir -p /home/vscode/.config/nvim/lua/plugins
COPY --chown=vscode:vscode nvim/plugins/colorscheme.lua /home/vscode/.config/nvim/lua/plugins/colorscheme.lua

RUN mise exec -- nvim --headless "+Lazy! sync" +qa

RUN mkdir -p /home/vscode/.config/opencode
COPY --chown=vscode:vscode opencode/ /home/vscode/.config/opencode/

COPY --chown=vscode:vscode .bashrc /home/vscode/.bashrc
