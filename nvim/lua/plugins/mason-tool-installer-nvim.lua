local tools = {
    { 'biome', version = '2.5.14' },
    { 'blade-formatter', version = '1.44.4' },
    { 'black', version = '26.5.1' },
    { 'ktfmt', version = 'v0.64' },
    { 'prettier', version = '3.9.5' },
    { 'prettierd', version = '0.29.0' },
    { 'prettypst', version = '2.0.0' },
    { 'ruff', version = '0.15.22' },
    { 'stylua', version = 'v2.5.2' },
    { 'tree-sitter-cli', version = 'v0.26.11' },
}

return {
    'WhoIsSethDaniel/mason-tool-installer.nvim',
    opts = {
        ensure_installed = tools,
        auto_update = false,
        run_on_start = false,
    },
}
