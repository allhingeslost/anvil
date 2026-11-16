FROM mcr.microsoft.com/devcontainers/base:ubuntu

RUN apt-get update && apt-get install -y --no-install-recommends \
    git curl build-essential gawk make wget ca-certificates \
    && rm -rf /var/lib/apt/lists/*

USER vscode
WORKDIR /home/vscode

ENV PATH="/home/vscode/.local/bin:/home/vscode/.local/share/mise/shims:$PATH"

RUN git clone --recursive --depth 1 --shallow-submodules https://github.com/akinomyoga/ble.sh.git && \
    make -C ble.sh install PREFIX=/home/vscode/.local && \
    rm -rf ble.sh

RUN curl -fsSL https://mise.run | sh

RUN mkdir -p /home/vscode/.config/mise
COPY --chown=vscode:vscode config.toml /home/vscode/.config/mise/config.toml

RUN /home/vscode/.local/bin/mise trust /home/vscode/.config/mise/config.toml && \
    /home/vscode/.local/bin/mise install

COPY --chown=vscode:vscode .bashrc /home/vscode/.bashrc
