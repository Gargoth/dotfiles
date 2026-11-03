# User-installed tools; these paths remain defined when Fish itself is symlinked.
set --global --export BUN_INSTALL "$HOME/.bun"

fish_add_path --global --path \
    "$HOME/.volta/bin" \
    "$BUN_INSTALL/bin" \
    "$HOME/.deno/bin" \
    "$HOME/.local/bin" \
    "$HOME/.local/share/bob/nvim-bin"

if status is-interactive
    # Optional interactive integrations.
    if type -q atuin
        atuin init fish --disable-up-arrow | source
    end

    # mise
    if type -q mise
        mise activate fish | source
    end
end
