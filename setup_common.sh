#!/usr/bin/env bash

install_common_toolchains() {
    local rust_installer
    rust_installer=$(mktemp)
    trap 'rm -f "$rust_installer"' RETURN
    curl --proto '=https' --tlsv1.2 -fsS https://sh.rustup.rs -o "$rust_installer"
    gum spin --title "Installing Rust toolchain..." -- sh "$rust_installer" -y
    rm -f "$rust_installer"
    trap - RETURN
    source "$HOME/.cargo/env"

    gum style --foreground 212 "Installing bob-nvim and Neovim 0.12.3..."
    local bob_installer
    bob_installer=$(mktemp)
    trap 'rm -f "$bob_installer"' RETURN
    curl -fsSL https://raw.githubusercontent.com/MordechaiHadad/bob/master/scripts/install.sh -o "$bob_installer"
    bash "$bob_installer"
    rm -f "$bob_installer"
    trap - RETURN
    "$HOME/.local/bin/bob" install v0.12.3
    "$HOME/.local/bin/bob" use v0.12.3

    gum style --foreground 212 "Installing Volta..."
    local volta_installer
    volta_installer=$(mktemp)
    trap 'rm -f "$volta_installer"' RETURN
    curl -fsSL https://get.volta.sh -o "$volta_installer"
    bash "$volta_installer"
    rm -f "$volta_installer"
    trap - RETURN

    gum spin --title "Installing Node.js with Volta..." -- \
        "$HOME/.volta/bin/volta" install node
    local bun_installer deno_installer
    bun_installer=$(mktemp)
    deno_installer=$(mktemp)
    trap 'rm -f "$bun_installer" "$deno_installer"' RETURN
    curl -fsSL https://bun.sh/install -o "$bun_installer"
    curl -fsSL https://deno.land/install.sh -o "$deno_installer"
    gum spin --title "Installing Bun..." -- bash "$bun_installer"
    gum spin --title "Installing Deno..." -- sh "$deno_installer"
    rm -f "$bun_installer" "$deno_installer"
    trap - RETURN

}

set_default_shell_to_fish() {
    gum spin --title "Changing default shell to Fish..." -- \
        sudo chsh -s "$(command -v fish)" "$USER"
}

show_setup_complete() {
    gum style --foreground 212 --margin "1" \
        "Setup Complete! Please log out and log back in, or restart your terminal, to use Fish."
    gum style --border normal --margin "1" --padding "1 2" --border-foreground 212 \
        "Reminder: Authenticate with GitHub" \
        "" \
        "1. gh auth login" \
        "2. gh auth setup-git"
}
