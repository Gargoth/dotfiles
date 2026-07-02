return {
    {
        'folke/which-key.nvim',
        event = 'VimEnter',
        config = function()
            local wk = require('which-key')
            wk.setup()

            -- Document existing key chains
            wk.add({
                {

                    { '<leader>L', group = '[L]SP' },
                    { '<leader>L_', hidden = true },
                    { '<leader>c', group = '[C]ode' },
                    { '<leader>c_', hidden = true },
                    { '<leader>d', group = '[D]ocument' },
                    { '<leader>d_', hidden = true },
                    { '<leader>s', group = '[S]earch' },
                    { '<leader>s_', hidden = true },
                    { '<leader>u', group = '[U]I' },
                    { '<leader>u_', hidden = true },
                    { '<leader>w', group = '[W]orkspace' },
                    { '<leader>w_', hidden = true },
                    { '<leader>x', group = '[x] Trouble' },
                    { '<leader>x_', hidden = true },
                    { '<leader>z', group = '[Z] Folds' },
                    { '<leader>z_', hidden = true },
                },
                -- visual mode
                {
                    mode = { 'v' }, -- NORMAL and VISUAL mode
                    { '<leader>h', group = 'Git [H]unk' },
                    { '<leader>h_', hidden = true },
                },
            })
        end,
    },
}
