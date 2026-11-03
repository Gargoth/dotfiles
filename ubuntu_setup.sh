#!/usr/bin/env bash
set -Eeuo pipefail
trap 'status=$?; printf "Setup failed at line %s: %s (exit %s)\n" "$LINENO" "$BASH_COMMAND" "$status" >&2; exit "$status"' ERR
# Do not allow this script or its child installers to read from a terminal.
exec </dev/null
source "$(dirname "${BASH_SOURCE[0]}")/setup_common.sh"

if [[ ! -r /etc/os-release ]]; then
    printf 'Cannot identify operating system: /etc/os-release is unavailable.\n' >&2
    exit 1
fi
source /etc/os-release
if [[ "${ID:-}" != ubuntu || "${VERSION_ID:-}" != 26.04 ]]; then
    printf 'Unsupported distribution: expected Ubuntu 26.04, found %s %s.\n' \
        "${ID:-unknown}" "${VERSION_ID:-unknown}" >&2
    exit 1
fi

# Fallback terminal type to fix Ghostty terminfo errors on Ubuntu
export TERM=xterm-256color

setup_header 'Starting system setup'

# Require sudo authorization that is already available without prompting.
if ! sudo -n true; then
    printf 'Noninteractive sudo authorization is required. Authenticate with sudo before running this script.\n' >&2
    exit 1
fi

# Ensure ~/.local/bin exists and add it to the PATH for this script session
mkdir -p "$HOME/.local/bin"
export PATH="$HOME/.local/bin:$PATH"

# Persist it to ~/.bashrc for future sessions if it isn't already there
if ! grep -q '\.local/bin' "$HOME/.bashrc"; then
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"
fi

# Install tools required to configure external repositories.
apt_options=(
    -o Dpkg::Options::=--force-confdef
    -o Dpkg::Options::=--force-confold
)
apt_get() {
    sudo -n env DEBIAN_FRONTEND=noninteractive NEEDRESTART_MODE=a \
        apt-get "$@" "${apt_options[@]}"
}

apt_get update -y
apt_get install -y ca-certificates curl

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
    python3-pip
    python3
    curl
    unzip
    yazi
)

# Add Yazi's official Debian and Ubuntu repository
setup_header 'Adding Yazi official repository...'
sudo -n mkdir -p /usr/share/keyrings
curl -fsSL https://yazi-rs.github.io/builds/yazi-keyring.gpg | sudo -n tee /usr/share/keyrings/yazi-keyring.gpg >/dev/null
printf 'deb [signed-by=/usr/share/keyrings/yazi-keyring.gpg] https://yazi-rs.github.io/builds/ stable main\n' \
    | sudo -n tee /etc/apt/sources.list.d/yazi.list >/dev/null

# Update system and install standard packages
setup_header 'Upgrading system and installing standard packages...'
apt_get update -y
apt_get full-upgrade -y

setup_header 'Installing apt packages...'
apt_get install -y "${packages[@]}"

# Install language toolchains and user applications
install_common_toolchains

# Change default shell to Fish
set_default_shell_to_fish
show_setup_complete
