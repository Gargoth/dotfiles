require('lsp').add('lua_ls')

vim.lsp.config('lua_ls', {
    settings = {
        Lua = {
            completion = {
                callSnippet = 'Replace',
            },
        },
    },
})

vim.lsp.enable('lua_ls')
