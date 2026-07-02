#!/usr/bin/env bash
set -e

# Fallback terminal type to fix Ghostty terminfo errors on Ubuntu
export TERM=xterm-256color

# Authenticate sudo upfront so hidden password prompts do not hang the script
sudo -v

# Ensure ~/.local/bin exists and add it to the PATH for this script session
mkdir -p "$HOME/.local/bin"
export PATH="$HOME/.local/bin:$PATH"

# Persist it to ~/.bashrc for future sessions if it isn't already there
if ! grep -q '\.local/bin' "$HOME/.bashrc"; then
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"
fi

# 1. Install gum via Charm's official apt repository
echo "Adding Charm repository and installing gum..."
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://repo.charm.sh/apt/gpg.key | sudo gpg --dearmor --yes -o /etc/apt/keyrings/charm.gpg
echo "deb [signed-by=/etc/apt/keyrings/charm.gpg] https://repo.charm.sh/apt/ * *" | sudo tee /etc/apt/sources.list.d/charm.list > /dev/null
sudo apt-get update -y
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y gum

# Clear screen and show a pretty start message
clear
gum style --border normal --margin "1" --padding "1 2" --border-foreground 212 "Starting System Setup"

packages=(
    atuin
    eza
    fastfetch
    fd-find
    fish
    fzf
    g++
    git
    git-delta
    gh
    golang-go
    make
    ripgrep
    tealdeer
    tmux
    poppler-utils
    python3-venv
    curl
    libfuse2
    unzip
    yazi
)

# 2. Add Yazi Debian repository
gum spin --title "Adding Yazi unofficial repository..." -- \
    sh -c "curl -sS https://debian.griffo.io/EA0F721D231FDD3A0A17B9AC7808B4DD62C41256.asc | sudo gpg --dearmor --yes -o /etc/apt/trusted.gpg.d/debian.griffo.io.gpg && echo \"deb https://debian.griffo.io/apt \$(lsb_release -sc 2>/dev/null) main\" | sudo tee /etc/apt/sources.list.d/debian.griffo.io.list > /dev/null"

# 3. Update system and install standard packages
gum spin --title "Upgrading system and installing standard packages..." -- \
    sh -c "sudo apt-get update && sudo DEBIAN_FRONTEND=noninteractive apt-get dist-upgrade -y"

gum spin --title "Installing apt packages..." -- \
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -y "${packages[@]}"

# 4. Install Rust toolchain non-interactively
gum spin --title "Installing Rust toolchain..." -- \
    sh -c "curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y"

source "$HOME/.cargo/env"

# 5. Install Bob natively
gum style --foreground 212 "Installing bob-nvim..."
curl -fsSL https://raw.githubusercontent.com/MordechaiHadad/bob/master/scripts/install.sh | bash

# 6. Install Volta natively
gum style --foreground 212 "Installing Volta..."
curl https://get.volta.sh | bash

# 7. Install JS runtimes via Volta
gum spin --title "Installing Node, Bun, and Deno..." -- \
    "$HOME/.volta/bin/volta" install node bun deno

# 8. Add paths to Fish
gum spin --title "Adding binaries to Fish path..." -- \
    fish -c "fish_add_path $HOME/.volta/bin $HOME/.local/bin $HOME/.local/share/bob/nvim-bin"

# 9. Install Beeper
mkdir -p "$HOME/Applications"
gum spin --title "Downloading Beeper..." -- \
    curl -sS -L -o "$HOME/Applications/Beeper.AppImage" "https://api.beeper.com/desktop/download/linux/x64/stable/com.automattic.beeper.desktop"

chmod +x "$HOME/Applications/Beeper.AppImage"

mkdir -p "$HOME/.local/share/applications"
cat <<EOF > "$HOME/.local/share/applications/beeper.desktop"
[Desktop Entry]
Name=Beeper
Exec="$HOME/Applications/Beeper.AppImage" --no-sandbox
Type=Application
Categories=Network;InstantMessaging;
Terminal=false
StartupWMClass=BeeperTexts
EOF

# 10. Change default shell to Fish
gum spin --title "Changing default shell to Fish..." -- \
    sudo chsh -s "$(which fish)" "$USER"

gum style --foreground 212 --margin "1" "Setup Complete! Please log out and log back in, or restart your terminal, to use Fish."

gum style --border normal --margin "1" --padding "1 2" --border-foreground 212 \
    "Reminder: Authenticate with GitHub" \
    "" \
    "1. gh auth login" \
    "2. gh auth setup-git"
