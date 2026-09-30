# Neovim configuration

## Requirements

- Neovim **0.12.3** (managed with [bob](https://github.com/MordechaiHadad/bob))
- [mise](https://mise.jdx.dev/) for the pinned local verification tools
- Python 3.9+, Git, C/C++ compilers, Node.js/npm, and Cargo for verification and plugin/tool builds
- Java for Kotlin formatting and PHP for PHPactor when working in those languages

The plugin versions are pinned by `lazy-lock.json`. Mason-managed servers and tools are pinned by exact versions in `lua/lsp/servers.lua` and `lua/plugins/mason-tool-installer-nvim.lua`. Verification tool versions are pinned in `mise.toml`.

These pins cover the direct dependencies. Mason's registry definitions and npm/pip/Cargo transitive dependency resolution are not locked; restoring a tool is not a byte-for-byte reproduction of its full dependency tree.

## Verify and maintain

```sh
mise trust
mise install              # Install pinned Neovim, Task, and StyLua
mise exec -- task setup   # Restore locked plugins and install pinned Mason tools
mise exec -- task check   # Syntax, formatting, startup, pins, and live Python integration
mise exec -- task doctor  # Selected tool versions and LSP health
```

All Neovim verification tasks use isolated XDG config, data, state, and cache directories under `.task/`. Run `task setup` before checking. Checks fail if dependencies are missing or drift from their pins; they do not silently skip integration tests or restore dependencies. With mise shell activation enabled, the `mise exec --` prefix is optional.

`task test` checks startup, resolved server configuration, installed dependency versions, formatter selection, and the autoformat policy. `task test:lsp` additionally verifies automatic `ty` attachment, an intentional type error, buffer-local inlay-hint toggling, and actual Python formatting. Errors produce a nonzero exit status. Live attachment of the other language servers is not covered.

For the normal Neovim installation, use `:Lazy restore` and `:MasonToolsInstallSync`. The Taskfile only restores the verification sandbox. Neovim's version is pinned independently for verification in mise; Bob can continue managing your daily editor.

## Upgrade pins

1. Update Neovim with Bob and adjust the exact version in `mise.toml`.
2. Update plugins deliberately with `:Lazy update`, then review and commit `lazy-lock.json`. Blink's binary release tags also live in its plugin specs and must match the lockfile commits.
3. Update Mason package versions in `lua/lsp/servers.lua` or `lua/plugins/mason-tool-installer-nvim.lua`.
4. Run `task setup`, `task check`, and `task doctor` and review the diff.

Mason automatic installation and updates are disabled during normal startup. `task setup` and `task restore` are explicit operations that install the versions declared in the configuration.

## Other dependencies

- `tree-sitter-cli` is a pinned standalone executable used by tree-sitter-manager; it is not an LSP server.
- `tree-sitter-manager.nvim` pins parser revisions in its upstream repository data. Automatic parser installation on newly opened filetypes is disabled.
- Install additional parsers explicitly with `:TSInstallSync`. Norg parsers are built directly from locked Git revisions as Neorg dependencies.
- `task doctor` reports upstream filetype warnings as diagnostic information; these are not all configuration failures.
