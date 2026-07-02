require('lsp').add('basedpyright')

vim.lsp.config('basedpyright', {
    settings = {
        basedpyright = {
            analysis = {
                typeCheckingMode = 'basic',
                -- Ensures indexing happens for installed third-party packages
                indexing = true,
                -- Allows the LSP to scan and index in the background
                userFileIndexingLimit = -1, -- No limit on indexed files
                -- Helps with performance/visibility across the workspace
                autoSearchPaths = true,
                useLibraryCodeForTypes = true,
                diagnosticMode = 'workspace',
            },
        },
    },
})

vim.lsp.enable('basedpyright')
