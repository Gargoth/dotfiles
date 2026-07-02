function gch
    git branch -r | fzf --tmux | xargs git checkout
end
