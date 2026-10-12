# Neovim Workflows

These recipes describe the current configuration. Installation, version pins,
tool reconciliation, and sandbox verification remain authoritative in
[`nvim/README.md`](../README.md).

## Review a Prepared Git Diff

The existing Fish workflow makes a temporary review branch:

```fish
preparebranchreview  # last commit against its parent
prepareprreview      # current branch against local origin default branch
```

Start from a named branch with a clean tree and no existing `temp` branch. The
helper records the return branch and performs a mixed reset on `temp`; your
original branch is not changed. `prepareprreview` does not fetch or inspect a
GitHub pull request. A mixed reset can leave added files untracked, so inspect
both `git status` and `git diff`.

For a read-only comparison, use `gd1` for the latest commit against its parent
or `gdpr [base-ref]` for `HEAD` against the local remote-default branch. These
helpers do not create `temp`, change branches, or include local working-tree
changes. They are useful when you want the same committed comparison without
the cleanup step.

Inside Neovim:

1. Press `Space sgs` to open Snacks Git status.
2. Use the picker preview to inspect files. Press `Ctrl+Q` to export selected
   entries, or all entries when none are selected, to quickfix.
3. Use `]q` and `[q` to move between changed files.
4. Use the Gitsigns gutter markers as the authoritative visual list of hunks
   in the current file. The markers distinguish additions, changes, and
   deletions relative to the current Git comparison base.
5. Use `]c` and `[c` to move between Gitsigns hunks. Press `Space p` to open
   the previous version of the current hunk and compare what changed.
6. Press `Space q` to toggle quickfix when you need more screen space.

When finished, return to Fish and run `cleantemp`. It can discard tracked and
untracked changes and delete commits unique to `temp`, but asks before doing so.
Do not use it as generic branch cleanup.

## Search to Quickfix

1. Use `Space sf` for files, `Space sgr` for grep, or `Space sdd` for
   diagnostics.
2. In the picker, use `Ctrl+Q` to export results.
3. Use `]q`/`[q` to traverse results and `Space q` to show or hide the list.

For diagnostics, `Space cq` populates a location list instead. Traverse it with
`]l`/`[l`, or open it with the Trouble `Space xL` mapping.

## LSP Navigation and Refactoring

LSP mappings appear only after a matching server attaches. Use `K` for hover,
`gd`/`gD` for definition/declaration, `gr`/`gI` for references/implementation,
`Space cr` for rename, and `Space ca` for code actions. `Space sw` searches
workspace symbols and `Space uh` toggles inlay hints when supported.

If a server is missing, opening the matching filetype triggers installation of
its pinned version. Formatting tools install similarly. `Space LI` checks LSP
health, `Space LL` opens the log, and `Space LR` restarts clients.

## Format Deliberately

Formatting is off on save by default. Use `Space cf` for the current buffer or
visual selection. Use `Space uf` to toggle format-on-save for the session.

Conform uses the configured pipelines and alternatives: Python runs Black then
Ruff fixes; JavaScript/TypeScript/JSON prefer Biome; Markdown/YAML prefer
prettierd or Prettier. The first use of a filetype may install the formatter;
opening a file does not automatically format it.

The Fish `nvimformat` helper formats tracked files one by one in headless
Neovim. It prompts when the repository is dirty but can rewrite accepted local
changes and does not roll back earlier files if a later file fails.

## Buffers, Windows, and Notes

- `Space Space` opens the buffer picker; press `Space` followed by the backtick
  key to switch to the alternate buffer.
- `Ctrl-h/j/k/l` moves between windows. `Alt-h/j/k/l` resizes them.
- `Space H`, `Space h`, and `Space 1` through `Space 9` use Harpoon.
- `Space nj` opens today’s journal. `Space ni` opens the default index and
  changes the working directory to that index’s directory.
- `Space nsll` and `Space nslf` insert Neorg links. Neorg defaults may be
  suppressed when they conflict with project mappings.

## Search and Replace

`Space S` opens GrugFar. Use its file and pattern fields to scope the operation,
review the preview, and treat replace/sync actions as edits across multiple
files. Save or review the affected buffers before leaving the picker.

## Terminal and Troubleshooting

Use `:terminal` for a native terminal. Press `Ctrl-\ Ctrl-N` to return to Normal
mode. Snacks explorer also offers a contextual terminal action with `Ctrl+T`.

Useful recovery commands include:

```vim
:Lazy
:Mason
:checkhealth vim.lsp
:TSInstallSync <language>
```

Use `:verbose nmap <key>` or the equivalent insert/terminal command to identify
which plugin owns a mapping. Some mappings are buffer-local, plugin-local, or
conditional and will not appear everywhere.
