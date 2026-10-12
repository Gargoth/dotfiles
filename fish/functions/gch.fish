function gch
    set -l refs (git for-each-ref --format='%(refname:short)' refs/remotes | string match -v '*/HEAD')
    or return
    if test (count $refs) -eq 0
        echo "No remote branches are available." >&2
        return 1
    end
    __select_branch 'Remote branch to track> ' no $refs
    or return
    set -l selected $__dotfiles_selected_branches
    set -e __dotfiles_selected_branches
    test (count $selected) -eq 1; or return 0
    set -l remote_ref "$selected[1]"
    set -l local_branch (string replace -r '^[^/]+/' '' -- "$remote_ref")
    if git show-ref --verify --quiet "refs/heads/$local_branch"
        git switch -- "$local_branch"
    else
        git switch --track -c "$local_branch" "$remote_ref"
    end
end
