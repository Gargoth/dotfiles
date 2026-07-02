function nv
    set -l suffix (basename (pwd))
    set -l socket_path ~/.cache/nvim/$suffix.pipe

    nvim --server $socket_path --remote-ui
end
