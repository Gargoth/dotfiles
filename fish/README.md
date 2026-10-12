# Fish User Guide

This directory contains the Fish configuration and its autoloaded functions.
The setup script installs Fish on Ubuntu 26.04, but individual helpers have
different prerequisites and platform limits. A missing optional CLI does not
mean the Fish configuration is broken.

## Configuration Layers

- `functions/` contains autoloaded public commands and internal helpers.
- `conf.d/` contains startup integrations, abbreviations, prompt behavior, and
  automatic virtual-environment activation.
- `completions/` contains small loaders that ask installed CLIs to generate
  their Fish completions.
- Node.js is managed with Volta. The setup script installs Volta and adds its
  bin directory to Fish’s path; project-specific pins are stored in
  `package.json`.

Start a new Fish shell after linking the configuration. The `sfish` abbreviation
is not a reliable way to reload every configuration file: it expands to one
`source` command with a glob and can repeat stateful startup hooks.

## Navigation and Neovim

| Command | Behavior |
| --- | --- |
| `repos [directory]` | Change to `$HOME/repos` or a child path. |
| `config [path]` | Change to `$HOME/repos/dotfiles` or a child path. |
| `neorg` | Create and enter `$HOME/Neorg`. |
| `dfzf` | Choose a file with `fzf --tmux` and enter its parent directory. |
| `v` | Find a file with `fd`/`fdfind` and open it in Neovim. |
| `nva` | Start or reuse a headless Neovim server for the current physical directory. |
| `nv` | Attach a Neovim remote UI to the server for the current physical directory. |
| `venv` | Activate `.venv/bin/activate.fish`, falling back to `venv/bin/activate.fish`. |

`nva` and `nv` use a project-path hash under `$XDG_CACHE_HOME/nvim` (or
`$HOME/.cache/nvim`). Run them from the same physical directory. `nva` does not
provide a stop command; close the headless server from Neovim when finished.

Entering a directory automatically deactivates the current environment and
sources that directory’s `.venv/bin/activate.fish` if it exists. This executes
project-provided shell code on directory changes, so only enter trusted
projects.

See [`nvim/docs/keybindings.md`](../nvim/docs/keybindings.md) and
[`nvim/docs/workflows.md`](../nvim/docs/workflows.md) for editor usage.

## Git and Review Helpers

| Command | Behavior | Warning |
| --- | --- | --- |
| `gd1` | Show the latest commit against its parent, matching `preparebranchreview`. | Committed changes only; local changes are excluded. |
| `gdpr [base-ref]` | Show `HEAD` against `origin/HEAD`, falling back to `origin/main`, matching `prepareprreview`. | Does not fetch; local changes are excluded. |
| `gitchanged [base-ref]` | List tracked files changed from the merge base with a base ref. Defaults to `origin/HEAD`, then `origin/main`. | Does not fetch and includes local tracked changes. |
| `git_stats [git-log-args...]` | Print chronological commit statistics. | Requires `awk`; output parsing expects Git’s English shortstat format. |
| `gh-starred` | List GitHub starred repositories. | Requires authenticated `gh`; no pagination is requested. |
| `gsw [query]` | Select and switch to a local branch with fzf. | Does not fetch. |
| `gch` | Select a remote-tracking branch and switch to or create its local tracking branch. | Does not fetch. |
| `cleangitbranch` | Select local branches and force-delete them. | Can delete unmerged branches; checked-out worktree branches are excluded. |
| `gri [count]` | Interactive rebase the last count commits, defaulting to one. | Rewrites history and may update related refs. |
| `git_reorder <count>` | Reorder commits through a temporary branch and interactive rebase. | Requires a clean tree and can leave recovery work on the temporary branch. |

### Review preparation

These commands deliberately change Git state. Start from a named branch with a
clean working tree and no existing `temp` branch:

```fish
preparebranchreview  # review the last commit
prepareprreview      # review against the local remote default branch
```

Both create `temp`, record the return branch, and perform a mixed reset. The
original branch is not changed. `prepareprreview` does not fetch, query GitHub,
or calculate a pull-request merge base. Inspect both `git status` and `git diff`:
added files can become untracked after a mixed reset.

When finished, run:

```fish
cleantemp
```

It confirms before discarding changes, deleting untracked files, or removing
commits unique to `temp`. Never use it as a generic cleanup command.

### Commit helpers

`gac [message words...]` stages with `git add .` and commits. `gca` amends the
latest commit without staging; `gaca [message words...]` stages and amends.
These operate from the current directory and the amend helpers rewrite history.

### Node versions

Use Volta for Node.js, npm, and package-manager versions:

```fish
volta install node
volta install npm
volta pin node@22
volta pin npm@latest
volta list
```

`volta pin` writes the project tool selection to `package.json`. Volta does not
automatically interpret `.nvmrc` or `.node-version` files; migrate those pins
explicitly. See `volta help` for the complete command surface.

## Git Abbreviations

The abbreviations in `conf.d/abbreviations.fish` expand interactively:

- Listing: `ls`, `la`, `ll`, `lt`, `ldir` use `eza`.
- Inspection: `gs`, `gd`, `gl`, `glb`.
- Mutation/network: `ga`, `ga.`, `gc`, `gf`, `gps`, `gpl`, `gr`, `grs`, `gswc`.
- tmux: `tm`, `tma`, `tms`, `tmks`.
- Multipass: `mp`, only when Multipass is installed.

`gspeedrebase` checks out “theirs”, stages every file, and continues a rebase.
It can overwrite conflict resolutions and should be used only when that is
intentional. `tmks` terminates every session on the selected tmux server.

## Compilation and Formatting

```fish
c source.c [compiler-options...]
cpp source.cpp [compiler-options...]
nvimformat
```

`c` uses `gcc` and `cpp` uses `clang++`; both compile to a temporary executable,
run it, and remove it. Compiler options are not runtime arguments. Compiled code
runs with your user permissions.

`nvimformat` formats tracked files one at a time through the configured Conform
pipeline. It prompts when the repository is dirty, but accepted formatting can
rewrite existing local changes and does not roll back earlier files on failure.
See the Neovim guide for formatter installation and filetype behavior.

## System and External Tools

| Command | Prerequisites and effects |
| --- | --- |
| `rec` | Requires `asciinema`; writes recordings under `$HOME/Documents/asciinema`. Recordings may contain secrets. |
| `setupDefaultSsh` | Reuses or starts an SSH agent and runs `ssh-add`; may load private keys and prompt for passphrases. |
| `mp-mount <instance> <path>` | Requires Multipass, SSHFS, and an RSA or Ed25519 key pair; adds the public key to the guest and mounts `/`. |
| `wifi_restart` | Requires NetworkManager; disconnects and reconnects Wi-Fi. |
| `theme` | Uses fzf to write WezTerm/Ghostty theme markers under the XDG config directory. |
| `watch-temporal-progress [seconds]` | Requires `watch`, Git, Temporal, Fish, and gum; displays Git and workflow counts without fetching. |

`mp-mount` assumes the guest user is `ubuntu`. Unmount its filesystem with
`umount <path>` or `fusermount -u <path>`.

## Automatic Integrations

Startup configuration conditionally integrates Starship, zoxide, direnv, Atuin,
mise, pyenv, rustup, and distrobox. Generated completion loaders exist for gh,
fx, Podman, Dagger, mise, LXC, and Temporal when those commands are installed.
On macOS, `python` aliases to `python3` when available. The `docker` and
`podman` aliases may route commands through `distrobox-host-exec` in interactive
shells.

The prompt, Fish vi-mode prompt, Puffer Fish expansions, and generated migration
files are shell behavior rather than public commands. Their exact availability
depends on the installed integrations and Fish version.
