-- For navigating quickly between manually set hot files

local keybinds = {
    {
        '<leader>H',
        function()
            require('harpoon'):list():add()
        end,
        desc = 'Harpoon file',
    },
    {
        '<leader>h',
        function()
            local harpoon = require('harpoon')
            harpoon.ui:toggle_quick_menu(harpoon:list())
        end,
        desc = 'Harpoon quick menu',
    },
}

-- Generate keybinds for navigation
for i = 1, 9, 1 do
    local new_keybind = {
        '<leader>' .. i,
        function()
            require('harpoon'):list():select(i)
        end,
        desc = 'Harpoon to file ' .. i,
    }
    table.insert(keybinds, new_keybind)
end

return {
    {
        'ThePrimeagen/harpoon',
        branch = 'harpoon2',
        opts = {
            menu = {
                width = vim.api.nvim_win_get_width(0) - 4,
            },
            settings = {
                save_on_toggle = true,
                sync_on_ui_close = true,
            },
        },
        keys = keybinds,
    },
}
