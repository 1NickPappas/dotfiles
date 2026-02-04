#!/bin/bash
# Install TPM (Tmux Plugin Manager) if not already installed

TPM_DIR="$HOME/.tmux/plugins/tpm"

if [ ! -d "$TPM_DIR" ]; then
    echo "Installing TPM (Tmux Plugin Manager)..."
    git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"
    echo "TPM installed. Run 'prefix + I' in tmux to install plugins."
else
    echo "TPM already installed at $TPM_DIR"
fi
