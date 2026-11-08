# Neovim configuration

User-facing mappings and workflows are documented in
[`docs/keybindings.md`](docs/keybindings.md) and
[`docs/workflows.md`](docs/workflows.md). The workflow guide includes the
Gitsigns gutter review flow and the Fish review helpers.

## Requirements

- Neovim **0.12.3** (managed with [bob](https://github.com/MordechaiHadad/bob))
- [mise](https://mise.jdx.dev/) for the pinned local verification tools
- Python 3.9+, Git, C/C++ compilers, Node.js/npm, and Cargo for verification and plugin/tool builds
- Java for Kotlin formatting and PHP for PHPactor when working in those languages

The plugin versions are pinned by `lazy-lock.json`. Mason owns language-server selection and versions; installed servers mapped by `mason-lspconfig` are enabled automatically. Standalone tools and formatters are pinned in `lua/tools/packages.lua`, with formatter aliases in `lua/tools/formatters.lua`. Verification tool versions are pinned in `mise.toml`.

These pins cover the direct dependencies. Mason's registry definitions and npm/pip/Cargo transitive dependency resolution are not locked; restoring a tool is not a byte-for-byte reproduction of its full dependency tree.

## Verify and maintain

```sh
mise trust
mise install              # Install pinned Neovim, Task, and StyLua
mise exec -- task setup   # Restore locked plugins and install pinned Mason tools
mise exec -- task test:install # Formatter first-use and Mason LSP lifecycle tests
mise exec -- task check   # Syntax, formatting, startup, pins, and live Python integration
mise exec -- task doctor  # Selected tool versions and LSP health
```

All Neovim verification tasks use isolated XDG config, data, state, and cache directories under `.task/`. Run `task setup` before checking. Checks fail if dependencies are missing or drift from their pins; they do not silently skip integration tests or restore dependencies. With mise shell activation enabled, the `mise exec --` prefix is optional.

`task test` checks startup, Mason-installed server activation, resolved server configuration, installed standalone tool versions, formatter selection, autoformat policy, and a real Neorg journal command. `task test:lsp` verifies the sandbox's Mason-installed Ty server activates without a registry refresh, attaches automatically, reports an intentional type error, supports buffer-local inlay-hint toggling, and works with actual Python formatting. Run `task test:install` once before the first `task check` to prepare the sandbox's Python tools and LSP fixture.

`task test:install` resets only the sandbox's Python tools (`ty`, Black, and Ruff), verifies formatter retry after a simulated registry outage, first-use formatter installation, repeated-event deduplication, and activation/deactivation when Ty is explicitly installed, uninstalled, and reinstalled through Mason. It requires network access. `task check:full` runs both fast checks and fresh-install checks. Errors produce a nonzero exit status. Live attachment of the other language servers is not covered.

Verification processes share an exclusive sandbox lock, route Neorg notes into `.task/notes`, and terminate the Neovim process group on timeout. Run verification tasks sequentially.

For the normal Neovim installation, use `:Lazy restore` and `:MasonToolsInstallSync` for standalone tools. Install and choose language servers yourself with `:Mason`; `mason-lspconfig` enables installed mapped servers at startup and after installation. Uninstalling a server disables it, and reinstalling it reactivates it. The Taskfile only restores the verification sandbox. Neovim's version is pinned independently for verification in mise; Bob can continue managing your daily editor.

## Upgrade pins

1. Update Neovim with Bob and adjust the exact version in `mise.toml`.
2. Update plugins deliberately with `:Lazy update`, then review and commit `lazy-lock.json`. Blink's binary release tags also live in its plugin specs and must match the lockfile commits.
3. Update standalone tool pins in `lua/tools/packages.lua`; choose language-server versions through Mason.
4. Run `task setup`, `task test:install`, `task check`, and `task doctor` and review the diff.

Mason-mapped language servers are enabled only when installed, either at startup or immediately after installation. Your `after/lsp/` overrides are applied to those servers, and they attach to matching open buffers. The config does not install or pin LSP versions; opening a filetype never installs an LSP. Mason maps both `ruff` and `stylua` as servers and formatter tools, so installing those formatter packages also enables their LSPs.

Correctly pinned standalone tools are usable without a registry refresh. Uninstalling an LSP disables it; reinstall it through Mason to enable it again.

Main formatters also install on opening their filetype. Python installs Black and Ruff; sequential formatter pipelines install each tool. Alternative lists install only their first choice (Biome for JavaScript/TypeScript/JSON, prettierd for Markdown/YAML). Formatting becomes available after installation completes; opening a file does not automatically format it. `<leader>uf` still controls format-on-save.

`task setup`, `task restore`, and `:MasonToolsInstallSync` install standalone tools and formatters, not language servers. Existing LSP installations are retained and enabled at startup; uninstalled LSPs remain disabled until you install them with Mason.

## Other dependencies

- `tree-sitter-cli` is a pinned standalone executable used by tree-sitter-manager; it is not an LSP server.
- `tree-sitter-manager.nvim` pins parser revisions in its upstream repository data. Automatic parser installation on newly opened filetypes is disabled.
- Install additional parsers explicitly with `:TSInstallSync`. Norg parsers are built directly from locked Git revisions as Neorg dependencies.
- `task doctor` reports upstream filetype warnings as diagnostic information; these are not all configuration failures.
