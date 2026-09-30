return {
    'WhoIsSethDaniel/mason-tool-installer.nvim',
    opts = {
        ensure_installed = require('tools.packages'),
        auto_update = false,
        run_on_start = false,
    },
}
