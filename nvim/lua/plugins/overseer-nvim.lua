return {
    'stevearc/overseer.nvim',
    ---@module 'overseer'
    ---@type overseer.SetupOpts
    opts = {},
    keys = {
        {
            '<leader>ot',
            ':OverseerToggle<CR>',
            mode = { 'n' },
            desc = '[O]verseer [T]oggle pane',
        },
        {
            '<leader>os',
            ':OverseerRun<CR>',
            mode = { 'n' },
            desc = '[O]verseer [S]earch Tasks',
        },
        {
            '<leader>of',
            function()
                local overseer = require('overseer')
                local tasks = overseer.list_tasks({ recent_first = true })
                if vim.tbl_isempty(tasks) then
                    vim.notify('No tasks found', vim.log.levels.WARN)
                else
                    overseer.run_action(tasks[1], 'open float')
                    vim.keymap.set('n', 'q', '<cmd>close<CR>', { buffer = true, desc = 'Close overseer float' })
                end
            end,
            mode = { 'n' },
            desc = 'Open last [O]verseer task in [F]loat',
        },
    },
}
