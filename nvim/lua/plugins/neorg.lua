return {
    "nvim-neorg/neorg",
    version = "*", -- Pin Neorg to the latest stable release
    lazy = false,
    priority = 0,
    dependencies = {
        require('plugins.neorg-telescope'),
        require('plugins.snacks'),
    },
    opts = {
        load = {
            ["core.defaults"] = {},
            ["core.concealer"] = {},
            ["core.dirman"] = {
                config = {
                    workspaces = {
                        default = "~/Neorg",
                    },
                    index = "index.norg",
                },
                ["core.journal"] = {
                    workspace = "default",
                }
            },
            ["core.integrations.telescope"] = {},
        }
    },
    keys = {
        {
            '<leader>nj',
            ':Neorg workspace default<CR>:Neorg journal today<CR>',
            desc = '[neorg] Create a journal entry for today',
        },
        {
            '<leader>ni',
            ':Neorg workspace default<CR>:Neorg index<CR>:cd %:p:h<CR>',
            desc = '[neorg] Go to default workspace index',
        },
        {
            '<leader>nmi',
            ':Neorg inject-metadata<CR>',
            desc = '[neorg] Inject metadata',
        },
        {
            '<leader>nmu',
            ':Neorg update-metadata<CR>',
            desc = '[neorg] Update metadata',
        },
        {
            '<leader>nss',
            ':Telescope neorg find_linkable<CR>',
            desc = '[neorg-telescope] Jump to any linkable',
        },
        {
            '<leader>nsf',
            ':Telescope neorg find_norg_files<CR>',
            desc = '[neorg-telescope] Find norg files',
        },
        {
            '<leader>nsll',
            ':Telescope neorg insert_link<CR>',
            desc = '[neorg-telescope] Insert link',
        },
        {
            '<leader>nslf',
            ':Telescope neorg insert_file_link<CR>',
            desc = '[neorg-telescope] Insert file link',
        },
        {
            '<leader>nr',
            function()
                Snacks.bufdelete.delete()
                local keys = vim.api.nvim_replace_termcodes('<C-6>', true, false, true)
                vim.api.nvim_feedkeys(keys, 'n', false)
            end,
            desc = '[neorg] Delete and reopen buffer to refresh'
        }
    }
}
