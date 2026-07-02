function cleantemp
    git clean -fd
    git restore .
    git switch -
    git branch -D temp
end
