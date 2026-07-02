-- This file reads the `current_theme` environment variable
-- and automatically sets the colorscheme to where it maps to if it exists.

-- NOTE: Catppuccin will be included as a neovim built-in
-- To accomodate this, the catppuccin plugin was renamed to catppuccin-nvim
-- Shouldn't need any changes here for now but it might affect this in the future.
local default_colorscheme = 'catppuccin'

local colorscheme_map = {
    ['catppuccin'] = 'catppuccin-mocha',
    ['gruvbox'] = 'gruvbox',
}

vim.cmd.colorscheme(colorscheme_map[vim.env.current_theme] or colorscheme_map[default_colorscheme])
