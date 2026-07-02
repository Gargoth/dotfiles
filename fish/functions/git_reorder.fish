function git_reorder
    if test $argv
        set -l branch_name (random)
        git switch -c "$branch_name"
        git rebase --update-refs -i "HEAD~$argv"
        git switch -
        git branch -D "$branch_name"
    else
        echo "Must supply a number as argument."
    end
end
