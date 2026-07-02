local function activate()
    require('lsp').add('svelte')
    vim.lsp.config('svelte', {})
    vim.lsp.enable('svelte')
end

local svelte = {
    activate = activate,
    filetypes = { 'svelte' },
    plugin = nil,
}

return svelte
