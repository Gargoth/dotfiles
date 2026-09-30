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

`task test` checks startup, resolved server configuration, installed dependency versions, formatter selection, and the autoformat policy. `task test:lsp` removes only the sandbox's Python tools (`ty`, Black, and Ruff), then verifies first-use installation, deduplication of repeated filetype events, automatic attachment, an intentional type error, buffer-local inlay-hint toggling, and actual Python formatting. This test requires network access. Errors produce a nonzero exit status. Live attachment of the other language servers is not covered.

For the normal Neovim installation, use `:Lazy restore` and `:MasonToolsInstallSync`. The Taskfile only restores the verification sandbox. Neovim's version is pinned independently for verification in mise; Bob can continue managing your daily editor.

## Upgrade pins

1. Update Neovim with Bob and adjust the exact version in `mise.toml`.
2. Update plugins deliberately with `:Lazy update`, then review and commit `lazy-lock.json`. Blink's binary release tags also live in its plugin specs and must match the lockfile commits.
3. Update Mason package versions in `lua/lsp/servers.lua` or `lua/plugins/mason-tool-installer-nvim.lua`.
4. Run `task setup`, `task check`, and `task doctor` and review the diff.

Language servers are installed asynchronously at their pinned versions only when a matching filetype is opened. After installation, the server attaches to existing matching buffers. Repeated filetype events share the pending install; failures are reported and another filetype event can retry. A previously installed version is reconciled to its pin on first use. Vue support is disabled.

Main formatters also install on opening their filetype. Python installs Black and Ruff; sequential formatter pipelines install each tool. Alternative lists install only their first choice (Biome for JavaScript/TypeScript/JSON, prettierd for Markdown/YAML). Formatting becomes available after installation completes; opening a file does not automatically format it. `<leader>uf` still controls format-on-save.

`task setup`, `task restore`, and `:MasonToolsInstallSync` install standalone tools and formatters, not the LSP list. Unused language servers can remain absent. Existing server installations are retained, but are enabled only after opening their filetypes.

## Other dependencies

- `tree-sitter-cli` is a pinned standalone executable used by tree-sitter-manager; it is not an LSP server.
- `tree-sitter-manager.nvim` pins parser revisions in its upstream repository data. Automatic parser installation on newly opened filetypes is disabled.
- Install additional parsers explicitly with `:TSInstallSync`. Norg parsers are built directly from locked Git revisions as Neorg dependencies.
- `task doctor` reports upstream filetype warnings as diagnostic information; these are not all configuration failures.
