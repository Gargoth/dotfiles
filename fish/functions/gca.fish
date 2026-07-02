function gca
    if test $argv
        git commit --amend -m $argv
    else
        git commit --amend
    end
end
