require('lsp').add('vtsls')

local modules = {
    require('lsp.svelte'),
    require('lsp.vue'),
}

local filetypes = { 'javascript', 'javascriptreact', 'javascript.jsx', 'typescript', 'typescriptreact', 'typescript.tsx' }

local plugins = {}

-- Iterate through modules, append filetypes, then activate them
for _, module in ipairs(modules) do
    for _, filetype in ipairs(module.filetypes) do
        table.insert(filetypes, filetype)
    end

    if module.plugin ~= nil then
        table.insert(plugins, module.plugin)
    end

    module.activate()
end

vim.lsp.config('vtsls', {
    filetypes = filetypes,
    settings = {
        vtsls = {
            tsserver = {
                globalPlugins = {
                    unpack(plugins),
                },
            },
        },
    },
})

vim.lsp.enable('vtsls')
