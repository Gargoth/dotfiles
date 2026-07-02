---@diagnostic disable: undefined-global
return {
    'folke/snacks.nvim',
    lazy = false,
    opts = {
        explorer = {},
        indent = {},
        picker = {},
    },
    keys = {
        {
            '\\',
            function()
                Snacks.explorer()
            end,
            desc = 'Toggle snacks explorer',
        },
        {
            '<leader><leader>',
            function()
                Snacks.picker.buffers()
            end,
            desc = '[S]earch buffers',
        },
        {
            '<leader>sS',
            function()
                Snacks.picker()
            end,
            desc = '[S]earch [S]nacks pickers',
        },
        {
            '<leader>sf',
            function()
                Snacks.picker.files()
            end,
            desc = '[S]earch [F]iles',
        },
        {
            '<leader>sgr',
            function()
                Snacks.picker.grep()
            end,
            desc = '[S]earch [G]rep',
        },
        {
            '<leader>sgs',
            function()
                Snacks.picker.git_status()
            end,
            desc = '[S]earch by [G]it [S]tatus',
        },
        {
            '<leader>sgb',
            function()
                Snacks.picker.git_branches()
            end,
            desc = '[S]earch by [G]it [B]ranches',
        },
        {
            '<leader>sdd',
            function()
                Snacks.picker.diagnostics()
            end,
            desc = '[S]earch [D]iagnostics',
        },
        {
            '<leader>sdb',
            function()
                Snacks.picker.diagnostics_buffer()
            end,
            desc = '[S]earch [D]iagnostics in [B]uffer',
        },
        {
            '<leader>sl',
            function()
                Snacks.picker.lazy()
            end,
            desc = '[S]earch [L]azy spec',
        },
        {
            '<leader>sr',
            function()
                Snacks.picker.resume()
            end,
            desc = '[R]esume previous search',
        },
        {
            '<leader>su',
            function()
                Snacks.picker.undo()
            end,
            desc = '[S]earch [u]ndos',
        },
        {
            '<leader>bdd',
            function()
                Snacks.bufdelete.delete()
            end,
            desc = '[B]uffer [D]elete current buffer',
        },
        {
            '<leader>bda',
            function()
                Snacks.bufdelete.all()
            end,
            desc = '[B]uffer [D]elete [A]ll',
        },
        {
            '<leader>bdo',
            function()
                Snacks.bufdelete.other()
            end,
            desc = '[B]uffer [D]elete [O]thers',
        },
    },
}
