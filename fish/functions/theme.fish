function theme
    if not command -q fzf
        echo "theme requires fzf." >&2
        return 127
    end
    set -l selection (printf 'gruvbox\ncatppuccin\n' | fzf --tmux)
    set -l picker_status $status
    if test $picker_status -eq 130; or test $picker_status -eq 1
        return 0
    else if test $picker_status -ne 0
        return $picker_status
    end
    if test (count $selection) -ne 1
        return 0
    end

    set -l selected_theme "$selection[1]"
    set -l config_home "$HOME/.config"
    if set -q XDG_CONFIG_HOME; and test -n "$XDG_CONFIG_HOME"
        set config_home "$XDG_CONFIG_HOME"
    end
    set -l ghostty_theme
    switch $selected_theme
        case gruvbox
            set ghostty_theme 'theme = Gruvbox Dark'
        case catppuccin
            set ghostty_theme 'theme = Catppuccin Mocha'
        case '*'
            echo "Unknown theme: $selected_theme" >&2
            return 2
    end

    if type -q wezterm
        command mkdir -p "$config_home/wezterm"; or return
        if not printf '%s\n' "$selected_theme" > "$config_home/wezterm/current_theme"
            echo "Failed to update WezTerm theme." >&2
            return 1
        end
    end
    if type -q ghostty
        command mkdir -p "$config_home/ghostty"; or return
        if not printf '%s\n' "$ghostty_theme" > "$config_home/ghostty/theme-current"
            echo "Failed to update Ghostty theme." >&2
            return 1
        end
    end
    set -gx current_theme "$selected_theme"

    if type -q ghostty
        echo "Press ctrl+shift+, to reload ghostty configuration"
    end
    echo "Current theme set to $selected_theme"
end
