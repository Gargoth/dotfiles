-- Formatter

return {
    'stevearc/conform.nvim',
    lazy = false,
    keys = {
        {
            '<leader>cf',
            function()
                require('conform').format({ async = true, lsp_fallback = true })
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
        format_on_save = function(bufnr)
            if not vim.g.autoformat then
                return
            end

            local disable_filetypes = {
                -- c = true,
                -- cpp = true
            }
            return {
                timeout_ms = 500,
                lsp_fallback = not disable_filetypes[vim.bo[bufnr].filetype],
            }
        end,
        formatters_by_ft = {
            lua = { 'stylua', 'lua_ls' },
            markdown = { 'prettierd', 'prettier' },
            yaml = { 'prettierd', 'prettier' },
            json = { 'biome', 'prettierd', 'prettier' },
            java = { 'checkstyle', 'jdtls' },
            python = { 'black', 'ruff', 'basedpyright' },
            kotlin = { 'ktfmt', 'ktlint' },
            javascript = { 'biome', 'prettierd', 'prettier' },
            typescript = { 'biome', 'prettierd', 'prettier' },
            blade = { 'blade-formatter' },
            typst = { 'prettypst', 'tinymist' },
        },
    },
}
