function gac
    if test $argv
        git add . && git commit -m $argv
    else
        git add . && git commit
    end
end
