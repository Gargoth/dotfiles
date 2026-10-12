function cleangitbranch --description "Interactively force-delete selected local branches"
    if not command -q git
        echo "cleangitbranch requires git." >&2
        return 127
    end
    set -l branches (git for-each-ref --format='%(refname:short)' refs/heads)
    if test $status -ne 0
        echo "Not in a Git repository or failed to list branches." >&2
        return 1
    end
    set -l checked_out
    set -l worktree_output (git worktree list --porcelain)
    if test $status -ne 0
        return 1
    end
    for line in $worktree_output
        if string match -rq '^branch refs/heads/' -- $line
            set -a checked_out (string replace 'branch refs/heads/' '' -- $line)
        end
    end

    set -l candidates
    set -l current (git branch --show-current)
    if test $status -ne 0
        return 1
    end
    for branch in $branches
        if test "$branch" != "$current"; and not contains -- "$branch" $checked_out
            set -a candidates "$branch"
        end
    end
    if test (count $candidates) -eq 0
        echo "No deletable local branches are available."
        return 0
    end

    if not command -q fzf
        echo "cleangitbranch requires fzf." >&2
        return 127
    end
    __select_branch 'Branches to force-delete> ' yes $candidates
    or return
    set -l selected $__dotfiles_selected_branches
    set -e __dotfiles_selected_branches
    if test (count $selected) -eq 0
        return 0
    end

    for branch in $selected
        if not contains -- "$branch" $candidates
            echo "Refusing unexpected branch name: $branch" >&2
            return 1
        end
    end
    printf 'Force-deleting selected branch: %s\n' $selected
    for branch in $selected
        git branch -D -- "$branch"
        or return
    end
end
