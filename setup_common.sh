#!/usr/bin/env bash

install_common_toolchains() {
    gum spin --title "Installing Rust toolchain..." -- \
        bash -o pipefail -c "curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y"
    source "$HOME/.cargo/env"

    gum style --foreground 212 "Installing bob-nvim and Neovim 0.12.3..."
    curl -fsSL https://raw.githubusercontent.com/MordechaiHadad/bob/master/scripts/install.sh | bash
    "$HOME/.local/bin/bob" install v0.12.3
    "$HOME/.local/bin/bob" use v0.12.3

    gum style --foreground 212 "Installing Volta..."
    curl -fsSL https://get.volta.sh | bash

    gum spin --title "Installing Node.js with Volta..." -- \
        "$HOME/.volta/bin/volta" install node
    gum spin --title "Installing Bun..." -- \
        bash -o pipefail -c 'curl -fsSL https://bun.sh/install | bash'
    gum spin --title "Installing Deno..." -- \
        bash -o pipefail -c 'curl -fsSL https://deno.land/install.sh | sh'

    gum spin --title "Adding binaries to Fish path..." -- \
        fish -c 'fish_add_path "$HOME/.volta/bin" "$HOME/.bun/bin" "$HOME/.deno/bin" "$HOME/.local/bin" "$HOME/.local/share/bob/nvim-bin"'
}

install_beeper() {
    mkdir -p "$HOME/Applications"
    gum spin --title "Downloading Beeper..." -- \
        curl -fsSL -L -o "$HOME/Applications/Beeper.AppImage" \
        "https://api.beeper.com/desktop/download/linux/x64/stable/com.automattic.beeper.desktop"
    chmod +x "$HOME/Applications/Beeper.AppImage"

    mkdir -p "$HOME/.local/share/applications"
    cat > "$HOME/.local/share/applications/beeper.desktop" <<EOF
[Desktop Entry]
Name=Beeper
Exec="$HOME/Applications/Beeper.AppImage" --no-sandbox
Type=Application
Categories=Network;InstantMessaging;
Terminal=false
StartupWMClass=BeeperTexts
EOF
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
