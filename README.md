# Dotfiles

Personal configuration for Fish, Neovim, tmux, Ghostty, WezTerm, and other tools.
The setup script targets Ubuntu 26.04; Fish-specific helpers also support macOS.

## Setup

The setup script installs packages and language runtimes on Ubuntu 26.04:

```sh
./ubuntu_setup.sh
```

The setup script requires `sudo` access and an interactive terminal. It installs Fish,
Bob, and Neovim 0.12.3, then installs Node.js with Volta and Bun and Deno with
their upstream installers.

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

## Neovim

Neovim dependencies, pinned tool versions, and isolated verification steps are
documented in [`nvim/README.md`](nvim/README.md). The Neovim verification suite
uses mise and Task; it does not modify the normal Neovim installation.

User guides are available for [Fish](fish/README.md) and Neovim's
[keybindings](nvim/docs/keybindings.md) and [workflows](nvim/docs/workflows.md).
