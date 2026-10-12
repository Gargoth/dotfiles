# bun
set --export BUN_INSTALL "$HOME/.bun"

# User-installed tools; these paths remain defined when Fish itself is symlinked.
fish_add_path --path \
    "$HOME/.volta/bin" \
    "$BUN_INSTALL/bin" \
    "$HOME/.deno/bin" \
    "$HOME/.local/bin" \
    "$HOME/.local/share/bob/nvim-bin"

if status is-interactive
    # Prompt and navigation integrations
    if type -q starship
        starship init fish | source
    end

    if type -q zoxide
        zoxide init fish | source
    end

    # direnv
    if type -q direnv
        direnv hook fish | source
    end

    # atuin
    if type -q atuin
        atuin init fish --disable-up-arrow | source
    end

    # mise
    if type -q mise
        mise activate fish | source
    end

    # Distrobox (Bazzite)
    if type -q distrobox-host-exec
        alias docker='distrobox-host-exec docker'
        alias podman='distrobox-host-exec podman'
    end

end
