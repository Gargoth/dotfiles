function dfzf --description "Go to parent directory of chosen file from fzf"
    set -l path (fzf --tmux)
    if test $path
        cd (dirname $path)
    end
end

