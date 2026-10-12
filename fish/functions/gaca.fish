function gaca
    if test (count $argv) -gt 0
        set -l message (string join ' ' -- $argv)
        git add .; or return
        git commit --amend "--message=$message"
    else
        git add .; or return
        git commit --amend
    end
end
