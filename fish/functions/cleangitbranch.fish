function cleangitbranch
    git branch | rg -v "main" | xargs git branch -D
end
