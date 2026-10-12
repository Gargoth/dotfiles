set -l config_home "$HOME/.config"
if set -q XDG_CONFIG_HOME; and test -n "$XDG_CONFIG_HOME"
    set config_home "$XDG_CONFIG_HOME"
end
if type -q wezterm; and test -r "$config_home/wezterm/current_theme"
    set -gx current_theme (string trim -- (command cat "$config_home/wezterm/current_theme"))
end
