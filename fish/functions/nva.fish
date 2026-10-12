function nva
    if test (count $argv) -ne 0
        echo "Usage: nva" >&2
        return 2
    end
    if not command -q nvim
        echo "nvim is not installed or not on PATH." >&2
        return 127
    end
    set -l project_path (pwd -P); or return
    set -l cache_home "$HOME/.cache"
    if set -q XDG_CACHE_HOME; and test -n "$XDG_CACHE_HOME"
        set cache_home "$XDG_CACHE_HOME"
    end
    set -l cache_dir "$cache_home/nvim"
    if not command -q shasum
        echo "nva requires shasum to identify the project socket." >&2
        return 127
    end
    set -l hash_output (printf '%s' "$project_path" | shasum -a 256)
    or return
    set -l socket_id (string split ' ' -- "$hash_output")[1]
    set -l socket_path "$cache_dir/$socket_id.sock"
    command mkdir -p "$cache_dir"; or return
    if test -S "$socket_path"
        if nvim --server "$socket_path" --remote-expr '1' >/dev/null 2>&1
            echo "Neovim server already running for $project_path."
            return 0
        end
        command rm -f -- "$socket_path"; or return
    else if test -e "$socket_path"
        echo "Refusing to replace non-socket path: $socket_path" >&2
        return 1
    end

    command nohup nvim --headless --listen "$socket_path" >/dev/null 2>&1 </dev/null &
    for attempt in (seq 1 50)
        if test -S "$socket_path"; and nvim --server "$socket_path" --remote-expr '1' >/dev/null 2>&1
            echo "Started Neovim server for $project_path."
            return 0
        end
        sleep 0.1
    end
    echo "Neovim server failed to start for $project_path." >&2
    return 1
end
