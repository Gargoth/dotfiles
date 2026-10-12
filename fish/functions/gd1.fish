function gd1 --description "Show the last commit as a review diff"
    if test (count $argv) -gt 0
        echo "Usage: gd1" >&2
        return 2
    end
    git rev-parse --verify HEAD~1 >/dev/null 2>&1; or return
    git diff HEAD~1 HEAD --
end
