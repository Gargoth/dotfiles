local vue_ls_path = vim.fn.stdpath('data') .. '/mason/packages/vue-language-server/node_modules/@vue/language-server'

local vue_plugin = {
    name = '@vue/typescript-plugin',
    location = vue_ls_path,
    languages = { 'vue' },
    configNamespace = 'typescript',
}

local function activate()
    require('lsp').add('vue_ls')
    vim.lsp.config('vue_ls', {})
    vim.lsp.enable('vue_ls')
end

local vue = {
    activate = activate,
    filetypes = { 'vue' },
    plugin = vue_plugin,
}

return vue
