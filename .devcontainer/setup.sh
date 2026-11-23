#!/bin/bash
set -e

sudo mount --make-rshared / || true

mkdir -p ~/.config/opencode ~/.local/share/opencode ~/.config/gh ~/.config/crush

if [ -f /tmp/setup/.gitconfig ]; then
    cp /tmp/setup/.gitconfig ~/.gitconfig
fi

if [ -d /tmp/setup/gh ]; then
    cp -rf /tmp/setup/gh/* ~/.config/gh/ 2>/dev/null || true
fi

if [ -f /tmp/setup/opencode-config/opencode.json ]; then
    cp /tmp/setup/opencode-config/opencode.json ~/.config/opencode/opencode.json
fi

if [ -f /tmp/setup/opencode-share/auth.json ]; then
    cp /tmp/setup/opencode-share/auth.json ~/.local/share/opencode/auth.json
fi

if [ -d /tmp/setup/crush ]; then
    cp -rf /tmp/setup/crush/* ~/.config/crush/ 2>/dev/null || true
fi

echo "DevBox Setup Complete!"