return {
    {
        'neovim/nvim-lspconfig',
        dependencies = {
            require('plugins.mason-nvim'),
            require('plugins.mason-lspconfig-nvim'),
            require('plugins.mason-tool-installer-nvim'),
            require('plugins.fidget-nvim'),
            require('plugins.lazydev'),
        },
        config = function()
            --  This function gets run when an LSP attaches to a particular buffer.
            vim.api.nvim_create_autocmd('LspAttach', {
                group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
                callback = function(event)
                    -- TODO: Maybe the following can be placed in the `keys` object instead
                    local map = function(keys, func, desc)
                        vim.keymap.set('n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
                    end

                    map('K', vim.lsp.buf.hover, 'Hover')
                    map('gd', vim.lsp.buf.definition, '[G]oto [D]efinition')
                    map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
                    map('gr', vim.lsp.buf.references, '[G]oto [R]eferences')
                    map('gI', vim.lsp.buf.implementation, '[G]oto [I]mplementation')
                    map('<leader>D', vim.lsp.buf.type_definition, 'Type [D]efinition')
                    map('<leader>cr', vim.lsp.buf.rename, '[C]ode [R]ename')
                    map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')
                    map('<leader>c[', vim.lsp.buf.incoming_calls, '[C]ode Incoming Calls')
                    map('<leader>c]', vim.lsp.buf.outgoing_calls, '[C]ode Incoming Calls')

                    map('<leader>sw', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[S]earch [W]orkspace')

                    -- Inlay hints
                    if client and client.server_capabilities.inlayHintProvider and vim.lsp.inlay_hint then
                        map('<leader>uh', function()
                            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
                        end, 'Toggle Inlay [H]ints')
                    end
                end,
            })

            -- Source all *.lua files under lua/lsp for lsp configurations
            vim.cmd('runtime! lua/lsp/*.lua')

            local lspconfig = require('lspconfig')
            local capabilities = require('blink.cmp').get_lsp_capabilities()

            local servers = {}

            require('mason').setup()
            local ensure_installed = require('lsp').servers
            vim.list_extend(ensure_installed, vim.tbl_keys(servers or {}))

            require('mason-tool-installer').setup({ ensure_installed = ensure_installed })

            ---@diagnostic disable-next-line: missing-fields
            require('mason-lspconfig').setup({
                handlers = {
                    -- Default handler for servers that are not explicitly handled
                    function(server_name)
                        local server = servers[server_name] or {}
                        server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})

                        -- Only configure and enable if not already configured
                        if not vim.lsp.get_config(server_name) then
                            vim.lsp.config(server_name, server)
                            vim.lsp.enable(server_name)
                        end
                    end,
                    -- TODO: Maybe remove this if it doesn't cause issues?
                    -- -- Override handlers to prevent conflicts with lua/lsp/*.lua files
                    -- lua_ls = function() end,
                    -- ts_ls = function() end,
                    -- jsonls = function() end,
                    -- gopls = function() end,
                    -- basedpyright = function() end,
                    -- fish_lsp = function() end,
                    -- angularls = function() end,    -- from fln_angular
                    -- intelephense = function() end, -- from fln_php
                    -- phpactor = function() end,     -- from fln_php
                    -- rust_analyzer = function() end,
                    -- sqlls = function() end,
                    -- svelte = function() end,
                    -- tailwindcss = function() end,
                    -- thriftls = function() end,
                    -- kotlin_lsp = function() end, -- already only uses vim.lsp.enable
                    -- twiggy_language_server = function() end,
                },
            })
        end,

        -- Disable virtual text
        vim.diagnostic.config({
            virtual_text = false,
        }),
    },
}
