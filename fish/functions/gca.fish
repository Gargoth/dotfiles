function gca
    if test (count $argv) -gt 0
        set -l message (string join ' ' -- $argv)
        git commit --amend "--message=$message"
    else
        git commit --amend
    end
end
