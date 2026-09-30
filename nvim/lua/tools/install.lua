local M = {}

function M.setup()
    local registry = require('mason-registry')
    local mapping = require('mason-lspconfig').get_mappings().lspconfig_to_package
    local servers = require('lsp.servers')
    local tool_versions = {}
    for _, tool in ipairs(require('tools.packages')) do
        tool_versions[tool[1]] = tool.version
    end
    local formatter_packages = require('tools.formatters')
    local pending = {}

    local function installed_version(package_name)
        local receipt = vim.fn.stdpath('data') .. '/mason/packages/' .. package_name .. '/mason-receipt.json'
        if vim.fn.filereadable(receipt) == 0 then
            return nil
        end
        local data = vim.json.decode(table.concat(vim.fn.readfile(receipt), '\n'))
        return data.source.id:match('@([^?]+)')
    end

    local function ensure(tool)
        if pending[tool.name] then
            return
        end
        pending[tool.name] = true

        local function complete(success, err)
            pending[tool.name] = nil
            if success then
                if tool.server then
                    -- enable() also starts the server for matching buffers already open.
                    local ok, activation_error = pcall(vim.lsp.enable, tool.name)
                    if not ok then
                        vim.notify(('Failed to enable %s: %s'):format(tool.name, activation_error), vim.log.levels.ERROR)
                    end
                end
            else
                vim.notify(('Failed to install %s@%s: %s'):format(tool.name, tool.version, tostring(err)), vim.log.levels.ERROR)
            end
        end

        local package_name = tool.server and assert(mapping[tool.name], 'missing Mason package mapping') or tool.name
        if installed_version(package_name) == tool.version then
            if not tool.server or not vim.lsp.is_enabled(tool.name) then
                complete(true)
            else
                pending[tool.name] = nil
            end
            return
        end

        registry.refresh(vim.schedule_wrap(function(success)
            if not success then
                complete(false, 'Mason registry refresh failed')
                return
            end
            local ok, err = pcall(function()
                local package = registry.get_package(package_name)
                if package:is_installed() and package:get_installed_version() == tool.version then
                    complete(true)
                elseif package:is_installing() then
                    local succeeded, failed
                    succeeded = vim.schedule_wrap(function()
                        package:off('install:failed', failed)
                        pending[tool.name] = nil
                        ensure(tool)
                    end)
                    failed = vim.schedule_wrap(function()
                        package:off('install:success', succeeded)
                        complete(false, 'Mason installation failed')
                    end)
                    package:once('install:success', succeeded)
                    package:once('install:failed', failed)
                else
                    package:install({ version = tool.version }, vim.schedule_wrap(complete))
                end
            end)
            if not ok then
                complete(false, err)
            end
        end))
    end

    registry:on(
        'package:uninstall:success',
        vim.schedule_wrap(function(package)
            for _, server in ipairs(servers) do
                if mapping[server.name] == package.name then
                    vim.lsp.enable(server.name, false)
                end
            end
        end)
    )

    local function on_filetype(buffer)
        if vim.bo[buffer].buftype ~= '' then
            return
        end
        local filetype = vim.bo[buffer].filetype
        for _, server in ipairs(servers) do
            local config = assert(vim.lsp.config[server.name], 'missing LSP configuration: ' .. server.name)
            if vim.list_contains(config.filetypes or {}, filetype) then
                ensure({ name = server.name, version = server.version, server = true })
            end
        end
        local formatters = require('conform').formatters_by_ft[filetype] or {}
        for _, formatter in ipairs(formatters) do
            local package_name = formatter_packages[formatter] or formatter
            ensure({ name = package_name, version = assert(tool_versions[package_name], 'missing formatter pin: ' .. package_name) })
            if formatters.stop_after_first then
                break
            end
        end
    end

    vim.api.nvim_create_autocmd('FileType', {
        group = vim.api.nvim_create_augroup('tool-install', { clear = true }),
        callback = function(event)
            on_filetype(event.buf)
        end,
    })
    for _, buffer in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_loaded(buffer) then
            on_filetype(buffer)
        end
    end
end

return M
