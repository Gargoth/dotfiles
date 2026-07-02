function gri
    if test $argv
        git rebase -i --update-refs HEAD~$argv
    else
        git rebase -i --update-refs HEAD~1
    end
end
