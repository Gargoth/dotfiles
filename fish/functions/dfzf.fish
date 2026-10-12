function dfzf --description "Go to parent directory of chosen file from fzf"
    if not command -q fzf
        echo "dfzf requires fzf." >&2
        return 127
    end
    set -l selected (fzf --tmux)
    set -l picker_status $status
    if test $picker_status -eq 130; or test $picker_status -eq 1
        return 0
    else if test $picker_status -ne 0
        return $picker_status
    end
    if test -z "$selected"
        return 0
    end
    cd -- (path dirname -- "$selected[1]")
end
