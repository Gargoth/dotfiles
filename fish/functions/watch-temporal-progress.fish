function watch-temporal-progress --description "Watch git sync progress and Temporal workflow counts"
    set -l interval 1
    if test (count $argv) -gt 1
        echo "Usage: watch-temporal-progress [interval-seconds]" >&2
        return 2
    end
    if test (count $argv) -eq 1
        set interval $argv[1]
    end
    if not string match -rq '^[0-9]+(\.[0-9]+)?$' -- "$interval"
        echo "Interval must be a positive number of seconds." >&2
        return 2
    end
    if test (math "$interval > 0") -ne 1
        echo "Interval must be a positive number of seconds." >&2
        return 2
    end
    for dependency in watch fish git temporal gum
        if not command -q "$dependency"
            echo "watch-temporal-progress requires $dependency." >&2
            return 127
        end
    end
    set -l remote_head (git symbolic-ref --quiet --short refs/remotes/origin/HEAD)
    if test $status -ne 0
        echo "origin/HEAD is not configured; fetch and set the remote's default branch first." >&2
        return 1
    end
    git rev-parse --verify "$remote_head^{commit}" >/dev/null; or return

    set -l script (string join '; ' \
        'set total_commits (git rev-list --count "$DOTFILES_WATCH_REMOTE")' \
        'set behind_commits (git rev-list --count "HEAD..$DOTFILES_WATCH_REMOTE")' \
        'if test $total_commits -gt 0; set progress_percent (math --scale=0 "(($total_commits - $behind_commits) * 100) / $total_commits"); else; set progress_percent 0; end' \
        'if test $progress_percent -lt 0; set progress_percent 0; end' \
        'if test $progress_percent -gt 100; set progress_percent 100; end' \
        'set filled_bar (string repeat --count $progress_percent "█")' \
        'set empty_bar (string repeat --count (math "100 - $progress_percent") "░")' \
        'set completed_workflows (temporal workflow count --query "ExecutionStatus=\"Completed\"" | string replace -ra "\r?\n" "" | string replace -r "^Total:[[:space:]]*" "")' \
        'set failed_workflows (temporal workflow count --query "ExecutionStatus=\"Failed\"" | string replace -ra "\r?\n" "" | string replace -r "^Total:[[:space:]]*" "")' \
        'set running_workflows (temporal workflow count --query "ExecutionStatus=\"Running\"" | string replace -ra "\r?\n" "" | string replace -r "^Total:[[:space:]]*" "")' \
        'gum style --foreground 212 "Progress: [$filled_bar$empty_bar] $progress_percent% ($behind_commits out of $total_commits commits)" "Temporal workflows - Completed: $completed_workflows | Failed: $failed_workflows | Running: $running_workflows"'
    )

    env DOTFILES_WATCH_REMOTE="$remote_head" watch -x -c -n "$interval" -- fish -c "$script"
end
