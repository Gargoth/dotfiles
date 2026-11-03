# Dotfiles

Personal configuration for Fish, Neovim, tmux, Ghostty, WezTerm, and other tools.
The setup script targets Ubuntu 26.04; Fish-specific helpers also support macOS.

## Setup

The setup script installs packages and language runtimes on Ubuntu 26.04:

```sh
./ubuntu_setup.sh
```

The setup script runs noninteractively and requires sudo authorization already
available to `sudo -n` for the duration of the run. In an interactive session,
run `sudo -v` first; automated jobs need passwordless sudo. The script fails
rather than prompting if authorization is unavailable or expires. APT keeps
existing modified configuration files when an upgrade presents a conflict and
automatically restarts affected services. The script performs a full system
upgrade. It uses colored section headers in interactive terminals (disabled by
`NO_COLOR`) and does not require Gum. It installs Fish, Bob, and Neovim 0.12.3,
then installs Node.js with Volta and Bun and Deno with their upstream
installers. Yazi is installed from its official upstream APT repository.

After installing packages, link all configurations with a preview first:

```sh
./create_config_symlinks.py --all --dry-run
./create_config_symlinks.py --all
```

Select individual configurations by directory name, or list available names:

```sh
./create_config_symlinks.py --list
./create_config_symlinks.py fish nvim tmux
```

The target defaults to `$XDG_CONFIG_HOME` or `~/.config`. Existing targets are
preserved as `.backup` siblings before links are created. Review and remove a
backup only after confirming it contains no files you need.

Install tmux plugins explicitly with `tmux/setup.sh`. It can be rerun to install
plugins declared in `tmux/tmux.conf`.

The shared tmux configuration supports Linux and macOS. It selects Fish for new
windows when Fish is found on `PATH` or in a common install location; if Fish is
not found, this configuration does not force a shell choice. This does not
change the account's login shell. On macOS, if
`reattach-to-user-namespace` is available, new windows launch Fish through it
for compatibility with tmux's clipboard integration.

## Neovim

Neovim dependencies, pinned tool versions, and isolated verification steps are
documented in [`nvim/README.md`](nvim/README.md). The Neovim verification suite
uses mise and Task; it does not modify the normal Neovim installation.

User guides are available for [Fish](fish/README.md) and Neovim's
[keybindings](nvim/docs/keybindings.md) and [workflows](nvim/docs/workflows.md).
