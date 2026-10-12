function v
    if not command -q fzf; or not command -q nvim
        echo "v requires fzf and nvim." >&2
        return 127
    end
    set -l finder fd
    if not command -q "$finder"
        set finder fdfind
    end
    if not command -q "$finder"
        echo "v requires fd or fdfind." >&2
        return 127
    end
    set -l file ($finder --type f --hidden -E .git -E node_modules | fzf --tmux)
    set -l picker_status $status
    if test $picker_status -eq 130; or test $picker_status -eq 1
        return 0
    else if test $picker_status -ne 0
        return $picker_status
    end
    if test -z "$file"
        return 0
    end
    nvim -- "$file[1]"
end
