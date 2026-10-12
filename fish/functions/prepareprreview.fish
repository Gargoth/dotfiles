function prepareprreview --description "Prepare an origin/main comparison as an unstaged review diff on temp"
    set -l original_branch (git symbolic-ref --quiet --short HEAD)
    or begin
        echo "Start from a named branch, not detached HEAD." >&2
        return 1
    end
    if test (count $argv) -ne 0
        echo "Usage: prepareprreview" >&2
        return 2
    end
    set -l dirty_state (git status --porcelain)
    or return
    if test (count $dirty_state) -gt 0
        echo "Commit or save your working tree changes before preparing a review." >&2
        return 1
    end
    if git show-ref --verify --quiet refs/heads/temp
        echo "Branch 'temp' already exists; review or clean it explicitly first." >&2
        return 1
    end
    set -l base_ref (git symbolic-ref --quiet --short refs/remotes/origin/HEAD)
    if test $status -ne 0; or test -z "$base_ref"
        set base_ref origin/main
    end
    git rev-parse --verify "$base_ref^{commit}" >/dev/null; or return

    git switch -c temp; or return
    if not git config branch.temp.dotfiles-return-to "$original_branch"
        git switch "$original_branch"
        git branch -D -- temp
        return 1
    end
    if not git reset --mixed "$base_ref"
        echo "Failed to prepare review; return to $original_branch and remove temp after inspection." >&2
        return 1
    end
end
