-- Provides breadcrumbs at the top of the editor and context navigation

return {
    'Bekaboo/dropbar.nvim',
    dependencies = require('plugins.telescope-fzf-native-nvim'),
    event = 'VeryLazy', -- Ensures the plugin loads so the API is available
    keys = {
        {
            '[;',
            function()
                require('dropbar.api').goto_context_start()
            end,
            desc = 'Go to start of current context',
        },
        {
            '];',
            function()
                require('dropbar.api').select_next_context()
            end,
            desc = 'Select next context',
        },
    },
}
