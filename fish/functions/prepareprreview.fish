function prepareprreview
    git branch -D temp
    git switch -c temp && \
        git reset --soft origin/main && \
        git commit -m "Temporary branch for review" && \
        git reset HEAD~1 --soft && \
        git restore --staged .
end
