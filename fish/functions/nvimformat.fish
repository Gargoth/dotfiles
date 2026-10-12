function nvimformat
    if not command -q nvim
        echo "nvimformat requires nvim." >&2
        return 127
    end
    set -l repo_root (git rev-parse --show-toplevel)
    or return
    if test (count $argv) -gt 0
        echo "Usage: nvimformat" >&2
        return 2
    end
    set -l dirty_state (git status --porcelain)
    or return
    if test (count $dirty_state) -gt 0
        printf 'nvimformat will rewrite tracked files, including existing local changes. Continue? [y/N] ' >&2
        read -l answer
        if test "$answer" != y; and test "$answer" != Y
            echo "Formatting cancelled."
            return 0
        end
    end
    set -l files (git ls-files -z | string split0)
    set -l listing_status $pipestatus[1]
    if test $listing_status -ne 0
        return $listing_status
    end
    set -l failures 0
    for file in $files
        if not test -f "$file"; or string match -rq '(^|/)\.gitmodules?$' -- "$file"
            continue
        end
        nvim --headless -n -c "lua local ok, err = pcall(function() local conform = require('conform'); local formatters, has_lsp = conform.list_formatters_to_run(0); if #formatters == 0 and not has_lsp then error('no formatter configured') end; local format_error = conform.format({ async = false, lsp_format = 'fallback' }); if format_error then error(format_error.message or tostring(format_error)) end; vim.cmd('write') end); if not ok then vim.api.nvim_err_writeln(tostring(err)); vim.cmd('cquit 1') else vim.cmd('quit') end" -- "$file"
        or set failures (math $failures + 1)
    end
    if test $failures -gt 0
        echo "Formatting failed for $failures file(s)." >&2
        return 1
    end
end
