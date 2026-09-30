#!/usr/bin/env bash
set -Eeuo pipefail
trap 'status=$?; printf "Setup failed at line %s: %s (exit %s)\n" "$LINENO" "$BASH_COMMAND" "$status" >&2; exit "$status"' ERR
source "$(dirname "${BASH_SOURCE[0]}")/setup_common.sh"

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

# Install tools required to configure external repositories.
sudo apt-get update -y
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y ca-certificates curl gnupg lsb-release

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
    bash -o pipefail -c 'curl -fsSL https://debian.griffo.io/EA0F721D231FDD3A0A17B9AC7808B4DD62C41256.asc | sudo gpg --dearmor --yes -o /etc/apt/trusted.gpg.d/debian.griffo.io.gpg && printf "deb https://debian.griffo.io/apt %s main\n" "$(lsb_release -sc)" | sudo tee /etc/apt/sources.list.d/debian.griffo.io.list > /dev/null'

# 3. Update system and install standard packages
gum spin --title "Upgrading system and installing standard packages..." -- \
    bash -c "sudo apt-get update && sudo DEBIAN_FRONTEND=noninteractive apt-get dist-upgrade -y"

gum spin --title "Installing apt packages..." -- \
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -y "${packages[@]}"

# 4. Install language toolchains and user applications
install_common_toolchains
install_beeper

# 5. Change default shell to Fish
set_default_shell_to_fish
show_setup_complete
