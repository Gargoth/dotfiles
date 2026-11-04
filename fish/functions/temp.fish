function temp --description "Create temp and reset the last N commits into the working tree"
    if test (count $argv) -ne 1
        echo "Usage: temp <non-negative-commit-count>" >&2
        return 2
    end
    set -l count $argv[1]
    if not string match -rq '^[0-9]+$' -- "$count"
        echo "Commit count must be a non-negative integer." >&2
        return 2
    end
    set -l original_branch (git symbolic-ref --quiet --short HEAD)
    or begin
        echo "Start from a named branch, not detached HEAD." >&2
        return 1
    end
    set -l dirty_state (git status --porcelain)
    or return
    if test (count $dirty_state) -gt 0
        echo "Commit or save your working tree changes before creating temp." >&2
        return 1
    end
    if git show-ref --verify --quiet refs/heads/temp
        echo "Branch 'temp' already exists; review or clean it explicitly first." >&2
        return 1
    end
    git rev-parse --verify "HEAD~$count" >/dev/null; or return

    git switch -c temp; or return
    if not git config branch.temp.dotfiles-return-to "$original_branch"
        git switch "$original_branch"
        git branch -D -- temp
        return 1
    end
    if not git reset --mixed "HEAD~$count"
        echo "Failed to prepare temp; return to $original_branch and remove temp after inspection." >&2
        return 1
    end
end
