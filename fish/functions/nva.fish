function nva
    set -l suffix (basename (pwd))
    set -l socket_path ~/.cache/nvim/$suffix.pipe

    if test -e $socket_path
        rm $socket_path
    end

    fish -c "nvim --headless --listen $socket_path" &
end
