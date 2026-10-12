function gdpr --description "Show the branch review diff against a remote base"
    if test (count $argv) -gt 1
        echo "Usage: gdpr [base-ref]" >&2
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

    git rev-parse --verify "$base_ref^{commit}" >/dev/null 2>&1
    if test $status -ne 0
        echo "Base ref '$base_ref' does not resolve to a commit." >&2
        return 1
    end
    git rev-parse --verify HEAD^{commit} >/dev/null 2>&1; or return
    git diff "$base_ref" HEAD --
end
