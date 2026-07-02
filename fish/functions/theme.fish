function theme
    set -Ux current_theme (printf "gruvbox\ncatppuccin" | fzf --tmux)
    if type -q "wezterm"
        echo $current_theme > ~/.config/wezterm/current_theme
    end

    # Ghostty
    switch $current_theme
        case gruvbox
            echo "theme = Gruvbox Dark" > ~/.config/ghostty/theme-current
        case catppuccin
            echo "theme = Catppuccin Mocha" > ~/.config/ghostty/theme-current
    end

    if type -q ghostty
        echo "Press ctrl+shift+, to reload ghostty configuration"
    end

    echo "Current theme set to $current_theme"
end
