return {
    {
        'neovim/nvim-lspconfig',
        dependencies = {
            require('plugins.mason-nvim'),
            require('plugins.mason-lspconfig-nvim'),
            require('plugins.mason-tool-installer-nvim'),
            require('plugins.fidget-nvim'),
            require('plugins.lazydev'),
            require('plugins.blink-cmp'),
        },
        config = function()
            vim.api.nvim_create_autocmd('LspAttach', {
                group = vim.api.nvim_create_augroup('lsp-attach', { clear = true }),
                callback = function(event)
                    local client = vim.lsp.get_client_by_id(event.data.client_id)
                    local function map(keys, func, desc)
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
                    map('<leader>c]', vim.lsp.buf.outgoing_calls, '[C]ode Outgoing Calls')
                    map('<leader>sw', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[S]earch [W]orkspace')

                    if client and client:supports_method('textDocument/inlayHint') then
                        map('<leader>uh', function()
                            local enabled = vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf })
                            vim.lsp.inlay_hint.enable(not enabled, { bufnr = event.buf })
                        end, 'Toggle Inlay [H]ints')
                    end
                end,
            })

            local servers = require('lsp.servers')
            local server_names = vim.tbl_map(function(server)
                return server.name
            end, servers)
            vim.lsp.enable(server_names)

            vim.diagnostic.config({ virtual_text = false })
        end,
    },
}
