function gri
    if test (count $argv) -gt 1
        echo "Usage: gri [positive-commit-count]" >&2
        return 2
    end
    set -l count 1
    if test (count $argv) -eq 1
        set count $argv[1]
    end
    if not string match -rq '^[1-9][0-9]*$' -- $count
        echo "Commit count must be a positive integer." >&2
        return 2
    end
    git rev-parse --verify "HEAD~$count" >/dev/null; or return
    git rebase -i --update-refs "HEAD~$count"
end
