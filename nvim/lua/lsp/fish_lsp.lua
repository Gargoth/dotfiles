require('lsp').add('fish_lsp')

vim.lsp.config('fish_lsp', {
    single_file_support = true,
})

vim.lsp.enable('fish_lsp')
