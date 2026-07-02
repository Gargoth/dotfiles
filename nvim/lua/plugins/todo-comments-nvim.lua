-- Highlight todo, notes, etc in comments

return {
    {
        'folke/todo-comments.nvim',
        dependencies = require('plugins.plenary-nvim'),
        opts = {},
        keys = {
            {
                ']t',
                ':lua require("todo-comments").jump_next()<CR>',
                desc = 'Jump to next todo comment',
            },
            {
                '[t',
                ':lua require("todo-comments").jump_prev()<CR>',
                desc = 'Jump to previous todo comment',
            },
            {
                '<leader>st',
                ':TodoTelescope<CR>',
                desc = 'Jump to previous todo comment',
            }
        }
    },
}
