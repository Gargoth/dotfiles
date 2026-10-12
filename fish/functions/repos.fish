function repos
    if test (count $argv) -gt 1
        echo "Usage: repos [directory]" >&2
        return 2
    end
    set -l repo_root "$HOME/repos"
    if not test -d "$repo_root"
        echo "Repository directory does not exist: $repo_root" >&2
        return 1
    end
    if test (count $argv) -eq 1
        cd -- "$repo_root/$argv[1]"
    else
        cd -- "$repo_root"
    end
end
