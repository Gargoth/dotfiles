function repos
    if test $argv
        cd ~/repos/$argv
    else
        cd ~/repos/
    end
end
