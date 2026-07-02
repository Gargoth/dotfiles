function gsw
    set -l targetBranch

    if test $argv
        set targetBranch (git branch | fzf --tmux --query "$argv" | string trim)
    else
        set targetBranch (git branch | fzf --tmux | string trim)
    end

    if test $targetBranch
        git switch $targetBranch
    end
end
