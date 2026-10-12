function preparebranchreview --description "Prepare the last commit as an unstaged review diff on temp"
    set -l original_branch (git symbolic-ref --quiet --short HEAD)
    or begin
        echo "Start from a named branch, not detached HEAD." >&2
        return 1
    end
    if test (count $argv) -ne 0
        echo "Usage: preparebranchreview" >&2
        return 2
    end
    set -l dirty_state (git status --porcelain)
    or return
    if test (count $dirty_state) -gt 0
        echo "Commit or save your working tree changes before preparing a review." >&2
        return 1
    end
    git show-ref --verify --quiet refs/heads/temp
    if test $status -eq 0
        echo "Branch 'temp' already exists; review or clean it explicitly first." >&2
        return 1
    end
    git rev-parse --verify HEAD~1 >/dev/null; or return

    git switch -c temp; or return
    if not git config branch.temp.dotfiles-return-to "$original_branch"
        git switch "$original_branch"
        git branch -D -- temp
        return 1
    end
    if not git reset --mixed HEAD~1
        echo "Failed to prepare review; return to $original_branch and remove temp after inspection." >&2
        return 1
    end
end
