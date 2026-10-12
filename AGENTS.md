# Repository Guidance

## Scope

This repository contains personal configuration for Fish, Neovim, tmux,
Ghostty, WezTerm, and related tools. These instructions apply to the whole
repository.

Keep changes focused on the requested configuration or documentation. Preserve
unrelated work in the working tree. Do not run setup scripts, create symlinks in
the normal home directory, install system packages, or update the normal
Neovim installation as part of routine verification unless explicitly asked.

The main entry points are:

- `ubuntu_setup.sh` provisions Ubuntu 26.04 and performs privileged changes.
- `create_config_symlinks.py` links selected configuration directories and can
  create `.backup` siblings.
- `tmux/setup.sh` installs the tmux plugin manager and configured plugins.
- `nvim/README.md` documents Neovim dependencies, verification, and upgrades.
- `fish/README.md` documents the public Fish command surface and shell hooks.

## Editing Conventions

- Prefer the smallest change that preserves the existing configuration style.
- Keep project-owned code separate from generated state and vendor-derived
  functions.
- Update user documentation in the same change when public functions,
  keybindings, workflows, defaults, dependencies, or version pins change.
- Do not describe optional tools as installed by the base setup unless the
  installer actually provisions them.
- Document destructive operations, confirmation behavior, scope, and recovery
  steps explicitly.
- Use ASCII unless the surrounding file already requires another character set.

## Neovim

The supported editor version is **Neovim 0.12.3**. Keep these references in
sync when changing the version:

- `setup_common.sh` selects the Bob version for the daily editor.
- `nvim/mise.toml` pins the verification editor.
- `nvim/tests/config_spec.lua` rejects version drift.
- `README.md` and `nvim/README.md` describe the supported version.

Neovim is initialized in `nvim/init.lua` and loads modular lazy.nvim specs from
`nvim/lua/plugins/`. Plugin revisions are recorded in `nvim/lazy-lock.json`.
Add or change plugins through a focused spec and review the resulting lockfile
change deliberately. Do not allow ordinary verification to update plugins or
the user’s normal data directory.

Language servers and tools are versioned in `nvim/lua/lsp/servers.lua` and
`nvim/lua/tools/packages.lua`. Installation and activation are on demand and
are coordinated by `nvim/lua/tools/install.lua`; do not assume every configured
server is installed or integration-tested.

The `nvim-lspconfig` plugin remains a source of server definitions, but its
legacy `require('lspconfig').SERVER.setup(...)` configuration API is deprecated.
Use Neovim’s native `vim.lsp.config` and `vim.lsp.enable` model. Follow this
repository’s existing pattern: put server overrides in `nvim/after/lsp/<name>.lua`,
resolve definitions through `vim.lsp.config`, and enable servers explicitly.
Do not reintroduce automatic Mason server enablement or legacy setup calls.

Formatting is configured by `nvim/lua/plugins/conform-nvim.lua` and is disabled
on save by default. Preserve formatter alternatives, ordered pipelines, and the
on-demand installation behavior when changing formatters or filetypes.

Use four-space indentation, preferred single quotes, and the 160-column limit
from `nvim/.stylua.toml` for Lua.

## Verification

Run Neovim checks from `nvim/`, using the pinned mise tools:

```sh
mise trust
mise install
mise exec -- task setup
mise exec -- task check
mise exec -- task doctor
```

Use `mise exec -- task test:install` when changing first-use installation,
retry, or recovery behavior. It requires network access and resets only the
sandbox’s Python tools. `mise exec -- task check:full` combines the fast and
fresh-install checks. Run verification tasks sequentially because they share an
exclusive sandbox lock. Report commands that were not run or were blocked; do
not claim unexecuted checks passed.

Fish has no equivalent test harness. For Fish changes, at minimum inspect the
function’s syntax and exercise behavior in a disposable repository or temporary
directory when the change affects Git state, files, processes, or credentials.
Do not test destructive helpers against the user’s real repositories or keys.

## Documentation

Keep these documents aligned with implementation:

- Root `README.md`: installation and configuration-linking entry points.
- `fish/README.md`: public Fish functions, abbreviations, hooks, prerequisites,
  side effects, and workflows.
- `nvim/README.md`: Neovim dependencies, pins, verification, and maintenance.
- `nvim/docs/keybindings.md`: active and important inherited keybindings.
- `nvim/docs/workflows.md`: user workflows built from the current mappings.

When a documented behavior is uncertain, inspect the source and prefer a
qualified statement over an inferred guarantee. Keep direct dependency pins and
the limits of test coverage explicit; Mason registry data and transitive
package dependencies are not fully locked.
