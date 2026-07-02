-- Pastel colorscheme

return {
    'catppuccin/nvim',
    name = 'catppuccin',
    priority = 1000,
    opts = {
        flavour = 'auto', -- latte, frappe, macchiato, mocha
        background = { -- :h background
            light = 'latte',
            dark = 'mocha',
        },
        transparent_background = true, -- disables setting the background color.
        show_end_of_buffer = false, -- shows the '~' characters after the end of buffers
        term_colors = false, -- sets terminal colors (e.g. `g:terminal_color_0`)
        dim_inactive = {
            enabled = false, -- dims the background color of inactive window
            shade = 'dark',
            percentage = 0.15, -- percentage of the shade to apply to the inactive window
        },
        no_italic = false, -- Force no italic
        no_bold = false, -- Force no bold
        no_underline = false, -- Force no underline
        styles = { -- Handles the styles of general hi groups (see `:h highlight-args`):
            comments = { 'italic' }, -- Change the style of comments
            conditionals = { 'italic' },
            loops = {},
            functions = {},
            keywords = {},
            strings = {},
            variables = {},
            numbers = {},
            booleans = {},
            properties = {},
            types = {},
            operators = {},
            -- miscs = {}, -- Uncomment to turn off hard-coded styles
        },
        color_overrides = {},
        custom_highlights = {},
        default_integrations = true,
        integrations = {
            -- See https://github.com/catppuccin/nvim#integrations
            aerial = true,
            dropbar = {
                enabled = true,
                color_mode = true, -- enable color for kind's texts, not just kind's icons
            },
            fidget = true, -- Used by LspConfig
            grug_far = true,
            harpoon = true,
            lsp_trouble = true,
            mason = true,
            snacks = {
                enabled = true,
            },
            which_key = true,
        },
    },
    config = function(_, opts)
        require('catppuccin').setup(opts)
    end,
}
