function preparebranchreview --description "Prepare the last commit as an unstaged review diff on temp"
    if test (count $argv) -ne 0
        echo "Usage: preparebranchreview" >&2
        return 2
    end
    temp 1
end
