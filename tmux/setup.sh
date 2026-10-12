#!/usr/bin/env bash
set -Eeuo pipefail

tpm_dir="$HOME/.tmux/plugins/tpm"
if [[ ! -d "$tpm_dir/.git" ]]; then
    mkdir -p "$(dirname "$tpm_dir")"
    git clone https://github.com/tmux-plugins/tpm "$tpm_dir"
fi

"$tpm_dir/bin/install_plugins"
