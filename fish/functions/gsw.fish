function gsw
    if test (count $argv) -gt 1
        echo "Usage: gsw [query]" >&2
        return 2
    end
    set -l query
    if test (count $argv) -eq 1
        set query --query "$argv[1]"
    end
    set -l refs (git for-each-ref --format='%(refname:short)' refs/heads)
    or return
    if test (count $refs) -eq 0
        echo "No local branches are available." >&2
        return 1
    end
    __select_branch 'Local branch> ' no $query $refs
    or return
    set -l selected $__dotfiles_selected_branches
    set -e __dotfiles_selected_branches
    test (count $selected) -eq 1; or return 0
    git switch -- "$selected[1]"
end
