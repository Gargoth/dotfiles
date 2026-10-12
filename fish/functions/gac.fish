function gac
    if test (count $argv) -gt 0
        set -l message (string join ' ' -- $argv)
        git add .; or return
        git commit "--message=$message"
    else
        git add .; or return
        git commit
    end
end
