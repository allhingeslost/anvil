FROM ubuntu:26.04

LABEL devcontainer.metadata='[{"remoteUser":"vscode","customizations":{"vscode":{"settings":{"terminal.integrated.defaultProfile.linux":"bash"}}}}]'

ARG DEBIAN_FRONTEND=noninteractive

RUN usermod -l vscode -d /home/vscode -m ubuntu && \
    groupmod -n vscode ubuntu && \
    chsh -s /bin/bash vscode && \
    apt-get update && apt-get install -y --no-install-recommends \
        sudo \
        locales \
        ca-certificates \
        curl \
        wget \
        git \
        procps \
        unzip \
        xz-utils \
        openssh-client \
        build-essential \
        gawk \
        less \
        file \
        tmux \
        podman \
        podman-docker \
        fuse-overlayfs \
        uidmap \
        slirp4netns \
        passt \
        crun \
        iptables \
    && echo "vscode ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/vscode \
    && chmod 0440 /etc/sudoers.d/vscode \
    && echo "en_US.UTF-8 UTF-8" > /etc/locale.gen \
    && locale-gen en_US.UTF-8 \
    && echo "vscode:100000:65536" >> /etc/subuid \
    && echo "vscode:100000:65536" >> /etc/subgid \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /etc/containers && touch /etc/containers/nodocker

COPY --chown=vscode:vscode .config/containers/ /home/vscode/.config/containers/

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

COPY --chown=vscode:vscode .config/mise/config.toml /home/vscode/.config/mise/config.toml

RUN mise install && mise cache clear

RUN git clone https://github.com/LazyVim/starter /home/vscode/.config/nvim && \
    rm -rf /home/vscode/.config/nvim/.git

COPY --chown=vscode:vscode .config/nvim/lua/plugins/colorscheme.lua /home/vscode/.config/nvim/lua/plugins/colorscheme.lua

RUN mise exec -- nvim --headless "+Lazy! sync" +qa

COPY --chown=vscode:vscode .config/opencode/ /home/vscode/.config/opencode/

COPY --chown=vscode:vscode .config/jj/config.toml /home/vscode/.config/jj/config.toml

COPY --chown=vscode:vscode .gitconfig /home/vscode/.gitconfig

COPY --chown=vscode:vscode .config/starship.toml /home/vscode/.config/starship.toml

COPY --chown=vscode:vscode .bashrc /home/vscode/.bashrc
