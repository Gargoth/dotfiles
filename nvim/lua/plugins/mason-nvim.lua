return {
    'mason-org/mason.nvim',
    config = true,
    keys = {
        {
            '<leader>cm',
            ':Mason<CR>',
            mode = { 'n' },
            desc = 'Toggle Mason',
        },
    },
}
