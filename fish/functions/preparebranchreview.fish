function preparebranchreview
    git branch -D temp
    git switch -c temp && git reset HEAD~1 --soft && git restore --staged .
end
