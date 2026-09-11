function watch-temporal-progress --description "Watch git sync progress and Temporal workflow counts"
    set -l interval 0.1
    if test (count $argv) -ge 1
        set interval $argv[1]
    end

    set -l script (string join '; ' \
        'set total_commits (git rev-list --count origin/HEAD)' \
        'set behind_commits (git rev-list --count HEAD..origin/HEAD)' \
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

    watch -c -n $interval -- "fish -c '$script'"
end
