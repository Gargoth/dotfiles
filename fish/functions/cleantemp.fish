function cleantemp --description "Discard a temp review diff and return to its source branch"
    if test (count $argv) -ne 0
        echo "Usage: cleantemp" >&2
        return 2
    end
    set -l current_branch (git symbolic-ref --quiet --short HEAD)
    or begin
        echo "Cannot clean a review from detached HEAD." >&2
        return 1
    end
    if test "$current_branch" != temp
        echo "Refusing cleanup: current branch is '$current_branch', not 'temp'." >&2
        return 1
    end
    set -l return_branch (git config --get branch.temp.dotfiles-return-to)
    or begin
        echo "No source branch recorded for this temp review." >&2
        return 1
    end
    git show-ref --verify --quiet "refs/heads/$return_branch"
    or begin
        echo "Recorded source branch '$return_branch' no longer exists." >&2
        return 1
    end

    set -l dirty_state (git status --porcelain)
    if test $status -ne 0
        echo "Failed to inspect repository state." >&2
        return 1
    end
    set -l unique_commits (git rev-list --count "$return_branch..temp")
    if test $status -ne 0
        echo "Failed to inspect commits unique to temp." >&2
        return 1
    end
    if test "$unique_commits" -gt 0
        read -P "Delete $unique_commits commit(s) unique to temp? [y/N] " answer
        if test "$answer" != y; and test "$answer" != Y
            echo "Cleanup cancelled."
            return 0
        end
    end
    if test (count $dirty_state) -gt 0
        git reset --hard; or return
        set -l repo_root (git rev-parse --show-toplevel); or return
        git -C "$repo_root" clean -fd; or return
        set -l remaining_changes (git status --porcelain)
        if test $status -ne 0; or test (count $remaining_changes) -gt 0
            echo "Cleanup left remaining changes; refusing to switch branches." >&2
            return 1
        end
    end
    git switch "$return_branch"; or return
    git branch -D -- temp; or return
    git config --remove-section branch.temp 2>/dev/null
end
