function gitchanged
    if test $argv
        git diff --name-only (git merge-base HEAD $argv)
    else
        git diff --name-only (git merge-base HEAD master)
    end
end
