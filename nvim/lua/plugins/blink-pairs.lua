-- Autocloses and pairs brackets, quotes, and spaces

return {
    'saghen/blink.pairs',
    version = '*',
    dependencies = 'saghen/blink.download',
    build = function() require('blink.pairs').download():pwait(60000) end,
    --- @module 'blink.pairs'
    --- @type blink.pairs.Config
    opts = {
        mappings = {
            enabled = true,
            cmdline = true,
            disabled_filetypes = {},
            pairs = {},
        },
        highlights = {
            enabled = false,
        },
        debug = false,
    },
}
