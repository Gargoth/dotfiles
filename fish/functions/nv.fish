function nv
    set -l project_path (pwd -P); or return
    if not command -q shasum
        echo "nv requires shasum to identify the project socket." >&2
        return 127
    end
    set -l cache_home "$HOME/.cache"
    if set -q XDG_CACHE_HOME; and test -n "$XDG_CACHE_HOME"
        set cache_home "$XDG_CACHE_HOME"
    end
    set -l cache_dir "$cache_home/nvim"
    if not command -q shasum
        echo "nv requires shasum to identify the project socket." >&2
        return 127
    end
    set -l hash_output (printf '%s' "$project_path" | shasum -a 256)
    or return
    set -l socket_id (string split ' ' -- "$hash_output")[1]
    set -l socket_path "$cache_dir/$socket_id.sock"
    if not test -S "$socket_path"
        echo "No Neovim server is listening for $project_path." >&2
        return 1
    end
    if not nvim --server "$socket_path" --remote-expr '1' >/dev/null 2>&1
        echo "Neovim server socket is stale: $socket_path" >&2
        return 1
    end
    nvim --server "$socket_path" --remote-ui
end
