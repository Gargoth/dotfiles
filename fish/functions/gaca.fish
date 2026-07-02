function gaca
    if test $argv
        git add .
        git commit --amend -m $argv
    else
        git add .
        git commit --amend
    end
end
