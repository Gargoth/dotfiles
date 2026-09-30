-- Formatter

return {
    'stevearc/conform.nvim',
    lazy = false,
    keys = {
        {
            '<leader>cf',
            function()
                require('conform').format({ async = true })
            end,
            mode = '',
            desc = '[C]ode [F]ormat buffer',
        },
        {
            '<leader>uf',
            function()
                vim.g.autoformat = not vim.g.autoformat
                print('Autoformat on save toggled to', vim.g.autoformat)
            end,
            mode = '',
            desc = 'Toggle Auto[f]ormat on Save',
        },
    },
    opts = {
        notify_on_error = false,
        default_format_opts = { lsp_format = 'fallback' },
        format_on_save = function()
            if not vim.g.autoformat then
                return
            end

            return {
                timeout_ms = 500,
            }
        end,
        formatters_by_ft = {
            lua = { 'stylua' },
            markdown = { 'prettierd', 'prettier', stop_after_first = true },
            yaml = { 'prettierd', 'prettier', stop_after_first = true },
            json = { 'biome', 'prettierd', 'prettier', stop_after_first = true },
            python = { 'black', 'ruff_fix' },
            kotlin = { 'ktfmt' },
            javascript = { 'biome', 'prettierd', 'prettier', stop_after_first = true },
            typescript = { 'biome', 'prettierd', 'prettier', stop_after_first = true },
            blade = { 'blade-formatter' },
            typst = { 'prettypst' },
        },
    },
}
