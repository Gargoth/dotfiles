function git_reorder
    if test (count $argv) -ne 1; or not string match -rq '^[1-9][0-9]*$' -- "$argv[1]"
        echo "Usage: git_reorder <positive-commit-count>" >&2
        return 2
    end

    set -l count $argv[1]
    set -l dirty_state (git status --porcelain)
    or return
    if test (count $dirty_state) -gt 0
        echo "Commit or stash working-tree changes before reordering." >&2
        return 1
    end
    git rev-parse --verify "HEAD~$count" >/dev/null; or return
    set -l original_branch (git symbolic-ref --quiet --short HEAD)
    or begin
        echo "Cannot reorder commits from a detached HEAD." >&2
        return 1
    end
    set -l temporary_branch "reorder-(random)-(random)"
    git switch -c "$temporary_branch"; or return
    if not git rebase --update-refs -i "HEAD~$count"
        echo "Rebase stopped. You remain on $temporary_branch to resolve or abort it." >&2
        return 1
    end
    git switch "$original_branch"; or return
    git reset --hard "$temporary_branch"; or begin
        echo "Rewritten commits are on $temporary_branch; return to it to recover." >&2
        return 1
    end
    git branch -D -- "$temporary_branch"
end
