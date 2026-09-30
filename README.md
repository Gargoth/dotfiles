# Dotfiles

Personal configuration for Fish, Neovim, tmux, Ghostty, WezTerm, and other tools.

## Setup

The setup scripts install packages and language runtimes for Ubuntu or openSUSE:

```sh
./ubuntu_setup.sh
# or
./opensuse_setup.sh
```

They require `sudo` access and an interactive terminal. The scripts install Fish,
Bob, and Neovim 0.12.3, then install Node.js with Volta and Bun and Deno with
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

## Neovim

Neovim dependencies, pinned tool versions, and isolated verification steps are
documented in [`nvim/README.md`](nvim/README.md). The Neovim verification suite
uses mise and Task; it does not modify the normal Neovim installation.
