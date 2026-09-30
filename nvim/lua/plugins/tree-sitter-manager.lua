return {
    'romus204/tree-sitter-manager.nvim',
    config = function()
        require('tree-sitter-manager').setup({
            ensure_installed = {}, -- Install explicitly with :TSInstallSync; revisions are pinned by the plugin lockfile.
            -- border = nil, -- border style for the window (e.g. "rounded", "single"), if nil, use the default border style defined by 'vim.o.winborder'. See :h 'winborder' for more info.
            auto_install = false,
            -- highlight = true, -- treesitter highlighting is enabled by default
            -- languages = {}, -- override or add new parser sources
        })
    end,
    keys = {
        {
            '<leader>ct',
            '<cmd>TSManager<cr>',
            desc = 'Toggle tree-sitter manager',
        },
    },
}
