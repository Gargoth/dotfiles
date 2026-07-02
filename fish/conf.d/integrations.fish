# App Shell Integrations
if type -q starship
    starship init fish | source
end

if type -q zoxide
    zoxide init fish | source
end

if type -q fzf
    fish_user_key_bindings
end

if type -q gh
  gh completion -s fish | source
end

# bun
set --export BUN_INSTALL "$HOME/.bun"
set --export PATH $BUN_INSTALL/bin $PATH

# direnv
if type -q direnv
    direnv hook fish | source
end

# atuin
if type -q atuin
    atuin init fish --disable-up-arrow | source
end

# fx
if type -q fx
    fx --comp fish | source
end

# podman
if type -q podman
    podman completion fish | source
end

# dagger
if type -q dagger
    dagger completion fish | source
end

# mise
if type -q mise
    mise completion fish | source
end

# Distrobox (Bazzite)
if type -q distrobox-host-exec
    alias docker='distrobox-host-exec docker'
    alias podman='distrobox-host-exec podman'
end

# Bob nvim version manager
if type -q bob
    fish_add_path "~/.local/share/bob/nvim-bin"
end

# LXD / LXC
if type -q lxc
    lxc completion fish | source
end
