function config
    if test $argv
        cd ~/repos/dotfiles/$argv
    else
        cd ~/repos/dotfiles
    end
end
