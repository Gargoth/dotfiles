function v
    set -l file (fd --type f --hidden -E "{.git,node_modules}" | fzf --tmux)
    if test $file
        nvim $file
    else
        echo "No file selected."
    end
end
