-- Fuzzy Finder (files, lsp, etc)

return {
    'nvim-telescope/telescope.nvim',
    event = 'VimEnter',
    dependencies = {
        require('plugins.plenary-nvim'),
        require('plugins.telescope-fzf-native-nvim'),
        require('plugins.telescope-ui-select-nvim'),
        require('plugins.nvim-web-devicons'),
    },
    config = function()
        require('telescope').setup({
            extensions = {
                ['ui-select'] = {
                    require('telescope.themes').get_dropdown(),
                },
            },
        })

        -- Enable Telescope extensions if they are installed
        pcall(require('telescope').load_extension, 'fzf')
        pcall(require('telescope').load_extension, 'ui-select')

        -- See `:help telescope.builtin`
        local builtin = require('telescope.builtin')
        -- NOTE: Most are disabled in favor of snacks

        -- vim.keymap.set('n', '<leader>sh', builtin.search_history, { desc = '[S]earch [H]istory' })
        -- vim.keymap.set('n', '<leader>sH', builtin.help_tags, { desc = '[S]earch [H]elp' })
        -- vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
        -- vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = '[S]earch [F]iles' })
        vim.keymap.set('n', '<leader>ss', builtin.treesitter, { desc = '[S]earch Treesitter [S]ymbols' })
        -- vim.keymap.set('n', '<leader>st', builtin.builtin, { desc = '[S]earch Select [T]elescope' })
        -- vim.keymap.set('n', '<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })
        -- vim.keymap.set('n', '<leader>sgr', builtin.live_grep, { desc = '[S]earch by [G][r]ep' })
        -- vim.keymap.set('n', '<leader>sgs', builtin.git_status, { desc = '[S]earch by [G]it [Status]' })
        -- vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
        -- vim.keymap.set('n', '<leader>sc', builtin.colorscheme, { desc = '[S]earch [C]olorscheme' })
        -- vim.keymap.set('n', '<leader>s.', builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
        -- vim.keymap.set('n', '<leader><leader>', builtin.buffers, { desc = '[ ] Find existing buffers' })
        -- vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = '[S]earch from [R]esumed picker' })

        -- New picker for git changed files
        local pickers = require('telescope.pickers')
        local finders = require('telescope.finders')
        local conf = require('telescope.config').values
        local git_changed_picker = function(opts)
            opts = opts or require('telescope.themes').get_dropdown({
                prompt_title = 'Git changed files from main',
            })
            pickers
                .new(opts, {
                    prompt_title = 'git_changed',
                    finder = finders.new_table({
                        results = vim.fn.systemlist('git diff --name-only main...HEAD'),
                    }),
                    sorter = conf.generic_sorter(opts),
                })
                :find()
        end
        vim.keymap.set('n', '<leader>sgc', git_changed_picker, { desc = '[S]earch [G]it [C]hanged files' })

        -- Fuzzy find in buffer
        vim.keymap.set('n', '<leader>/', function()
            builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown({
                winblend = 10,
                previewer = false,
            }))
        end, { desc = '[/] Fuzzily search in current buffer' })
    end,
}
