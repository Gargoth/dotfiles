function config
    if test (count $argv) -gt 1
        echo "Usage: config [path]" >&2
        return 2
    end
    set -l config_root "$HOME/repos/dotfiles"
    if test (count $argv) -eq 1
        cd -- "$config_root/$argv[1]"
    else
        cd -- "$config_root"
    end
end
