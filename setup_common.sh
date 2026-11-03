#!/usr/bin/env bash

setup_header() {
    if [[ -t 1 && -z "${NO_COLOR:-}" ]]; then
        printf '\033[1;35m%s\033[0m\n' "$1"
    else
        printf '%s\n' "$1"
    fi
}

install_common_toolchains() {
    local rust_installer
    rust_installer=$(mktemp)
    trap 'rm -f "$rust_installer"' RETURN
    curl --proto '=https' --tlsv1.2 -fsS https://sh.rustup.rs -o "$rust_installer"
    setup_header 'Installing Rust toolchain...'
    sh "$rust_installer" -y
    rm -f "$rust_installer"
    trap - RETURN
    source "$HOME/.cargo/env"

    setup_header 'Installing bob-nvim and Neovim 0.12.3...'
    local bob_installer
    bob_installer=$(mktemp)
    trap 'rm -f "$bob_installer"' RETURN
    curl -fsSL https://raw.githubusercontent.com/MordechaiHadad/bob/master/scripts/install.sh -o "$bob_installer"
    bash "$bob_installer"
    rm -f "$bob_installer"
    trap - RETURN
    "$HOME/.local/bin/bob" install v0.12.3
    "$HOME/.local/bin/bob" use v0.12.3

    setup_header 'Installing Volta...'
    local volta_installer
    volta_installer=$(mktemp)
    trap 'rm -f "$volta_installer"' RETURN
    curl -fsSL https://get.volta.sh -o "$volta_installer"
    bash "$volta_installer"
    rm -f "$volta_installer"
    trap - RETURN

    setup_header 'Installing Node.js with Volta...'
    "$HOME/.volta/bin/volta" install node
    local bun_installer deno_installer
    bun_installer=$(mktemp)
    deno_installer=$(mktemp)
    trap 'rm -f "$bun_installer" "$deno_installer"' RETURN
    curl -fsSL https://bun.sh/install -o "$bun_installer"
    curl -fsSL https://deno.land/install.sh -o "$deno_installer"
    setup_header 'Installing Bun...'
    bash "$bun_installer"
    setup_header 'Installing Deno...'
    sh "$deno_installer" -y
    rm -f "$bun_installer" "$deno_installer"
    trap - RETURN

}

set_default_shell_to_fish() {
    setup_header 'Changing default shell to Fish...'
    sudo -n chsh -s "$(command -v fish)" "$USER"
}

show_setup_complete() {
    setup_header 'Setup complete. Please log out and back in, or restart your terminal, to use Fish.'
    setup_header 'Reminder: authenticate with GitHub'
    printf '  1. gh auth login\n  2. gh auth setup-git\n'
}
