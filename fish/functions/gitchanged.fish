function gitchanged
    if test (count $argv) -gt 1
        echo "Usage: gitchanged [base-ref]" >&2
        return 2
    end
    set -l base_ref
    if test (count $argv) -eq 1
        set base_ref $argv[1]
    else
        set base_ref (git symbolic-ref --quiet --short refs/remotes/origin/HEAD)
        if test $status -ne 0; or test -z "$base_ref"
            set base_ref origin/main
        end
    end
    git rev-parse --verify "$base_ref^{commit}" >/dev/null
    if test $status -ne 0
        echo "Base ref '$base_ref' does not resolve to a commit." >&2
        return 1
    end
    set -l merge_base (git merge-base HEAD "$base_ref")
    if test $status -ne 0; or test -z "$merge_base"
        echo "Could not find a common ancestor with '$base_ref'." >&2
        return 1
    end
    git diff --name-only "$merge_base"
end
