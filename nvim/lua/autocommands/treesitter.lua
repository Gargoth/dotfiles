-- Automatically start treesitter highlighting for all supported filetypes
-- This replaces the highlighting functionality previously managed by nvim-treesitter

-- Associate the 'typescriptreact' filetype with the 'tsx' parser
vim.treesitter.language.register('tsx', 'typescriptreact')

local group = vim.api.nvim_create_augroup('native_treesitter', { clear = true })

vim.api.nvim_create_autocmd('FileType', {
    group = group,
    pattern = '*',
    callback = function(args)
        pcall(vim.treesitter.start, args.buf)
    end,
})
