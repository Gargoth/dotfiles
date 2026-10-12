function __select_branch --argument-names prompt multi
    if not command -q fzf
        echo "Branch selection requires fzf." >&2
        return 127
    end
    set -l args $argv[3..-1]
    set -l query
    if test "$multi" != yes
        if test (count $args) -gt 0; and test "$args[1]" = --query
            set query --query "$args[2]"
            set args $args[3..-1]
        end
    end
    set -l candidates $args
    if test (count $candidates) -eq 0
        echo "No branches available to select." >&2
        return 1
    end
    if test "$multi" = yes
        set -g __dotfiles_selected_branches (printf '%s\n' $candidates | fzf --multi --tmux --prompt="$prompt")
    else
        set -g __dotfiles_selected_branches (printf '%s\n' $candidates | fzf --tmux $query --prompt="$prompt")
    end
    set -l picker_status $status
    if test $picker_status -eq 130; or test $picker_status -eq 1
        set -e __dotfiles_selected_branches
        return 0
    else if test $picker_status -ne 0
        set -e __dotfiles_selected_branches
        return $picker_status
    end
end
