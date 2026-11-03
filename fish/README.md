# Fish User Guide

This directory contains the Fish configuration and its autoloaded functions.
The setup script installs Fish on Ubuntu 26.04, but individual helpers have
different prerequisites and platform limits. A missing optional CLI does not
mean the Fish configuration is broken.

## Configuration Layers

- `functions/` contains autoloaded public commands and internal helpers.
- `conf.d/` contains environment setup, interactive integrations,
  abbreviations, and prompt behavior.
- `completions/` contains small loaders that ask installed CLIs to generate
  their Fish completions.
- Node.js is managed with Volta. The setup script installs Volta and adds its
  bin directory to Fish’s path; project-specific pins are stored in
  `package.json`.

Start a new Fish shell after linking the configuration.

## Navigation and Neovim

| Command | Behavior |
| --- | --- |
| `repos [directory]` | Change to `$HOME/repos` or a child path. |
| `config [path]` | Change to `$HOME/repos/dotfiles` or a child path. |
| `neorg` | Create and enter `$HOME/Neorg`. |
| `dfzf` | Choose a file with `fzf --tmux` and enter its parent directory. |

See [`nvim/docs/keybindings.md`](../nvim/docs/keybindings.md) and
[`nvim/docs/workflows.md`](../nvim/docs/workflows.md) for editor usage.

## Git and Review Helpers

| Command | Behavior | Warning |
| --- | --- | --- |
| `gd1` | Show the latest commit against its parent, matching `preparebranchreview`. | Committed changes only; local changes are excluded. |
| `gdpr [base-ref]` | Show `HEAD` against `origin/HEAD`, falling back to `origin/main`, matching `prepareprreview`. | Does not fetch; local changes are excluded. |
| `git_stats [git-log-args...]` | Print chronological commit statistics. | Requires `awk`; output parsing expects Git’s English shortstat format. |
| `gh-starred` | List GitHub starred repositories. | Requires authenticated `gh`; no pagination is requested. |
| `gsw [query]` | Select and switch to a local branch with fzf. | Does not fetch. |
| `gch` | Select a remote-tracking branch and switch to or create its local tracking branch. | Does not fetch. |
| `cleangitbranch` | Select local branches and force-delete them. | Can delete unmerged branches; checked-out worktree branches are excluded. |
| `gri [count]` | Interactive rebase the last count commits, defaulting to one. | Rewrites history and may update related refs. |

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

### Python projects

Use uv to manage project environments and run tools without activating a shell
environment:

```fish
uv sync
uv run pytest
```

Fish does not automatically activate a project's `.venv`.

## Git Abbreviations

The abbreviations in `conf.d/abbreviations.fish` expand interactively:

- Listing: `ls`, `la`, `ll`, `lt`, `ldir` use `eza`.
- Inspection: `gs`, `gd`, `gl`, `glb`.
- Mutation/network: `ga`, `ga.`, `gc`, `gf`, `gps`, `gpl`, `gr`, `grs`, `gswc`.
- tmux: `tm`, `tma`, `tms`, `tmks`.
- Multipass: `mp`, only when Multipass is installed.

`tmks` terminates every session on the selected tmux server.

## System and External Tools

| Command | Prerequisites and effects |
| --- | --- |
| `mp-mount <instance> <path>` | Requires Multipass, SSHFS, and an RSA or Ed25519 key pair; adds the public key to the guest and mounts `/`. |
| `theme` | Uses fzf to write WezTerm/Ghostty theme markers under the XDG config directory. |

`mp-mount` assumes the guest user is `ubuntu`. Unmount its filesystem with
`umount <path>` or `fusermount -u <path>`.

## Automatic Integrations

Interactive startup conditionally initializes Atuin and mise. Rustup's Fish
environment file is sourced when present; Volta, Bun, Deno, local tools, and Bob's
Neovim binary directories are added to `PATH` when present. Python projects use
uv directly; Fish does not automatically activate project environments.
Generated completion loaders exist for gh, fx, Podman, Dagger, mise, LXC, and
Temporal when those commands are installed. Hydro supplies the prompt on both
macOS and Linux.

Hydro, the Fish vi-mode prompt, and Puffer Fish expansions are shell behavior
rather than public commands. Optional integrations and completion loaders are
enabled only when their commands are installed.
