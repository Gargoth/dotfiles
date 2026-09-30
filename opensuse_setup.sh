#!/usr/bin/env bash
set -Eeuo pipefail
trap 'status=$?; printf "Setup failed at line %s: %s (exit %s)\n" "$LINENO" "$BASH_COMMAND" "$status" >&2; exit "$status"' ERR
source "$(dirname "${BASH_SOURCE[0]}")/setup_common.sh"

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

# Install tools required to configure external repositories.
sudo zypper --non-interactive refresh
sudo zypper --non-interactive install ca-certificates curl gpg2

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

# 3. Install language toolchains and user applications
install_common_toolchains
install_beeper

# 4. Change default shell to Fish
set_default_shell_to_fish
show_setup_complete
