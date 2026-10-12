# Neovim Keybindings

The leader and local leader are both `Space`. A mapping marked **attached** is
available only when the current buffer has the required plugin, LSP client, or
Git repository context. Plugin pickers and explorers have their own local
maps that override general navigation while they are open.

## Core

| Keys | Mode | Action |
| --- | --- | --- |
| `Esc` | Normal | Clear search highlighting. |
| `Space Space` | Normal | Open the Snacks buffer picker. |
| `Space q` | Normal | Toggle the quickfix window. It does not populate quickfix. |
| `Space cq` | Normal | Set the **location list** from diagnostics. |
| `Space ce` | Normal | Show diagnostics in a floating window. |
| `[d` / `]d` | Normal | Previous/next diagnostic. |
| `Ctrl-h/j/k/l` | Normal | Move between windows. |
| `Space` followed by `` ` `` | Normal | Switch to the alternate buffer. |
| `Space yy` | Normal | Yank the whole buffer to the system `+` register. |

## Search and Files

| Keys | Action |
| --- | --- |
| `\` | Toggle the Snacks file explorer. |
| `Space sf` | Find files with Snacks. |
| `Space sgr` | Grep with Snacks. |
| `Space sgs` | Open Git status in Snacks. |
| `Space sgb` | Pick a Git branch. |
| `Space sr` | Resume the previous Snacks picker. |
| `Space ss` | Search Tree-sitter symbols with Telescope. |
| `Space /` | Search the current buffer with Telescope. |
| `Space S` | Open GrugFar search and replace. |

In generic Snacks pickers, `Ctrl+Q` exports selected entries, or all results
when nothing is selected, to quickfix. `Enter` opens an entry; `Ctrl+V`, `Ctrl+S`,
and `Ctrl+T` use alternate split, horizontal split, and tab actions where the
picker provides them. In Git pickers, `Tab` stages or unstages and `Ctrl+R`
restores; they are not harmless selection keys.

Native `]q` and `[q` move through quickfix. Native `]l` and `[l` move through a
location list. Use `Space q` to show or hide quickfix, or `Space xQ` for the
Trouble quickfix panel.

## Git Changes

These mappings are **attached** when Gitsigns is active:

| Keys | Action |
| --- | --- |
| `]c` / `[c` | Next/previous Git hunk; in a diff window, use native diff navigation. |
| `Space p` | Preview the current hunk. |
| `Space ub` | Toggle current-line blame. |
| `Space uD` | Toggle deleted-line display. |
| `Space cb` | Open the blame view. |
| Visual `Space hs` | Stage the selected hunk. |
| Visual `Space hr` | Reset the selected hunk. |

Gitsigns also marks additions, changes, and deletions in the sign column. During
a review, use those gutter signs together with `]c`/`[c` to see the complete
hunk-level change set. `Space p` previews the previous content for the current
hunk; it is the quickest way to inspect what the edited lines replaced.

The Fish review helpers and their reset/cleanup behavior are documented in
[`fish/README.md`](../../fish/README.md).

## LSP and Diagnostics

LSP mappings are buffer-local and appear after a server attaches:

| Keys | Action |
| --- | --- |
| `K` | Hover documentation. |
| `gd` / `gD` | Definition/declaration. |
| `gr` / `gI` | References/implementation. |
| `Space D` | Type definition. |
| `Space cr` | Rename. |
| `Space ca` | Code action. |
| `Space c[` / `Space c]` | Incoming/outgoing calls. |
| `Space sw` | Dynamic workspace symbols. |
| `Space uh` | Toggle inlay hints when supported by the client. |
| `Space sdd` / `Space sdb` | All/current-buffer diagnostics in Snacks. |
| `Space xx` / `Space xX` | All/current-buffer diagnostics in Trouble. |
| `Space cl` | LSP results in Trouble. |

For LSP troubleshooting, `Space LI` runs `:checkhealth vim.lsp`, `Space LL`
opens the LSP log, and `Space LR`/`Space LS` restart or stop LSP clients.

## Formatting and Editing

| Keys | Mode | Action |
| --- | --- | --- |
| `Space cf` | Normal/Visual/Select | Format the buffer or selected range through Conform. |
| `Space uf` | Normal/Visual/Select | Toggle format-on-save. It starts off. |
| `Space uc` | Normal | Toggle conceal level. |
| `Space uw` | Normal | Toggle wrap and linebreak. |
| `gcc` / `gbc` | Normal | Comment or block-comment the current line through Comment.nvim. |
| `gc` / `gb` | Normal/Visual | Comment or block-comment a motion/selection. |

Blink completion uses its default preset: `Ctrl+Space` opens completion,
`Ctrl+Y` accepts, `Ctrl+E` cancels, and `Ctrl+N/P` or arrows navigate. `Tab` and
`Shift+Tab` move through snippet placeholders. Enter is not the configured
completion acceptance key.

## Navigation, Notes, and Tools

- `Space H` adds a file to Harpoon; `Space h` opens its menu; `Space 1` through
  `Space 9` select entries.
- `Space nj` opens today’s Neorg journal; `Space ni` opens the index and changes
  the working directory to its location. `Space nsll` and `Space nslf` insert
  links.
- `Space cm` opens Mason and `Space ct` opens the Tree-sitter manager. Parser
  auto-install is disabled; use `:TSInstallSync` explicitly.
- `:terminal` opens a native terminal. Press `Ctrl-\ Ctrl-N` to leave terminal
  input mode. There is no project-wide terminal toggle mapping.
- `Space bdd`, `Space bda`, and `Space bdo` delete the current, all, or other
  buffers through Snacks. Treat the all/other actions as state-changing.

Use `:verbose nmap <key>`, `:verbose imap <key>`, or `:verbose tmap <key>` to
find the mapping that won precedence in the current context. Project mappings
and plugin defaults can be suppressed by conflicts, filetype, or attachment.
