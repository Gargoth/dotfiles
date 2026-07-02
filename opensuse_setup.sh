#!/usr/bin/env bash
set -e

# Fallback terminal type to fix Ghostty terminfo errors
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

# 1. Install gum via Charm's official RPM repository
echo "Adding Charm repository and installing gum..."
sudo rpm --import https://repo.charm.sh/yum/gpg.key
echo '[charm]
name=Charm
baseurl=https://repo.charm.sh/yum/
enabled=1
gpgcheck=1
gpgkey=https://repo.charm.sh/yum/gpg.key' | sudo tee /etc/zypp/repos.d/charm.repo > /dev/null
sudo zypper --non-interactive refresh
sudo zypper --non-interactive install gum

# Clear screen and show a pretty start message
clear
gum style --border normal --margin "1" --padding "1 2" --border-foreground 212 "Starting System Setup"

packages=(
    atuin
    eza
    fastfetch
    fd
    fish
    fzf
    gcc-c++
    git
    git-delta
    gh
    go
    make
    ripgrep
    tealdeer
    tree-sitter
    tmux
    poppler-tools
    curl
    libfuse2
    unzip
    yazi
)

# 2. Update system and install standard packages
gum spin --title "Upgrading system and installing standard packages..." -- \
    sh -c "sudo zypper --non-interactive dup"

gum spin --title "Installing zypper packages..." -- \
    sudo zypper --non-interactive install "${packages[@]}"

# 3. Install Rust toolchain non-interactively
gum spin --title "Installing Rust toolchain..." -- \
    sh -c "curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y"

source "$HOME/.cargo/env"

# 4. Install Bob natively
gum style --foreground 212 "Installing bob-nvim..."
curl -fsSL https://raw.githubusercontent.com/MordechaiHadad/bob/master/scripts/install.sh | bash

# 5. Install Volta natively
gum style --foreground 212 "Installing Volta..."
curl https://get.volta.sh | bash

# 6. Install JS runtimes via Volta
gum spin --title "Installing Node, Bun, and Deno..." -- \
    "$HOME/.volta/bin/volta" install node bun deno

# 7. Add paths to Fish
gum spin --title "Adding binaries to Fish path..." -- \
    fish -c "fish_add_path $HOME/.volta/bin $HOME/.local/bin $HOME/.local/share/bob/nvim-bin"

# 8. Install Beeper
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

# 9. Change default shell to Fish
gum spin --title "Changing default shell to Fish..." -- \
    sudo chsh -s "$(which fish)" "$USER"

gum style --foreground 212 --margin "1" "Setup Complete! Please log out and log back in, or restart your terminal, to use Fish."

gum style --border normal --margin "1" --padding "1 2" --border-foreground 212 \
    "Reminder: Authenticate with GitHub" \
    "" \
    "1. gh auth login" \
    "2. gh auth setup-git"
