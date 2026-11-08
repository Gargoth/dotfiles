local function fail(message)
    error(message, 2)
end

local function assert_equal(actual, expected, message)
    if not vim.deep_equal(actual, expected) then
        fail(('%s\nexpected: %s\nactual: %s'):format(message, vim.inspect(expected), vim.inspect(actual)))
    end
end

local function wait_until(predicate, timeout_ms, message)
    if not vim.wait(timeout_ms, predicate, 50) then
        fail(message)
    end
end

local source = debug.getinfo(1, 'S').source:sub(2)
local config_dir = vim.fn.fnamemodify(source, ':p:h:h')
local version = vim.version()
assert_equal({ version.major, version.minor, version.patch }, { 0, 12, 3 }, 'Neovim version drift')
local function read_lua_module(path)
    return dofile(config_dir .. '/lua/' .. path:gsub('%.', '/') .. '.lua')
end

local ty_config = assert(vim.lsp.config.ty, 'ty did not resolve from native configuration')
if ty_config.settings.ty.diagnosticMode ~= 'workspace' then
    fail('ty must resolve with workspace diagnostics enabled')
end

local vtsls_config = assert(vim.lsp.config.vtsls, 'vtsls did not resolve from native configuration')
assert(not vim.list_contains(vtsls_config.filetypes, 'vue'), 'Vue must not select vtsls')
assert(vim.list_contains(vtsls_config.filetypes, 'svelte'), 'Svelte vtsls support must remain')

local mason_config = read_lua_module('plugins.mason-lspconfig-nvim').opts
assert_equal(mason_config.automatic_enable, true, 'Mason-installed servers must be enabled')
assert(mason_config.ensure_installed == nil, 'Mason must not bulk-install language servers')

local installer_config = read_lua_module('plugins.mason-tool-installer-nvim').opts
local tools_by_name = {}
for _, item in ipairs(installer_config.ensure_installed) do
    if type(item) ~= 'table' or not item.version then
        fail(('Mason package %s is missing an exact version'):format(vim.inspect(item)))
    end
    tools_by_name[item[1]] = item.version
end
if not tools_by_name['tree-sitter-cli'] then
    fail('tree-sitter-cli must be installed as a pinned standalone tool')
end

local formatter_config = read_lua_module('plugins.conform-nvim').opts
assert_equal(formatter_config.formatters_by_ft.python, { 'black', 'ruff_fix' }, 'Python formatting must use Black and Ruff fixes')
for filetype, formatters in pairs(formatter_config.formatters_by_ft) do
    for _, formatter in ipairs(formatters) do
        assert(require('conform.formatters.' .. formatter), 'unknown formatter for ' .. filetype)
    end
end

-- Verify selection using real installed formatters, so alternatives cannot run sequentially.
local buffer = vim.api.nvim_create_buf(false, true)
vim.api.nvim_buf_call(buffer, function()
    vim.cmd('noautocmd setfiletype javascript')
end)
local formatters = require('conform').list_formatters_to_run(buffer)
assert_equal(
    vim.tbl_map(function(formatter)
        return formatter.name
    end, formatters),
    { 'biome' },
    'JavaScript must run only the first available formatter'
)
vim.api.nvim_buf_delete(buffer, { force = true })

local save_policy = formatter_config.format_on_save
vim.g.autoformat = false
assert(save_policy() == nil, 'autoformat-off must skip save formatting')
vim.g.autoformat = true
assert(save_policy() ~= nil, 'autoformat-on must enable save formatting')
vim.g.autoformat = false

local actual_enabled = vim.tbl_map(function(config)
    return config.name
end, vim.lsp.get_configs({ enabled = true }))
local installed_servers = require('mason-lspconfig').get_installed_servers()
table.sort(actual_enabled)
table.sort(installed_servers)
assert_equal(actual_enabled, installed_servers, 'only installed Mason servers must be enabled at startup')
for _, name in ipairs(installed_servers) do
    local config = vim.lsp.config[name]
    assert(config.cmd and config.filetypes, 'missing executable or filetypes for ' .. name)
end

local registry = require('mason-registry')
local requests = {}
registry:on('package:install:handle', function(handle)
    requests[#requests + 1] = handle.package.name
end)
local unrelated = vim.api.nvim_create_buf(true, false)
vim.bo[unrelated].filetype = 'text'
vim.api.nvim_exec_autocmds('FileType', { buffer = unrelated })
vim.wait(100, function()
    return false
end)
assert_equal(requests, {}, 'unconfigured filetypes must not request tool installs')
vim.api.nvim_buf_delete(unrelated, { force = true })

local lockfile = vim.json.decode(table.concat(vim.fn.readfile(config_dir .. '/lazy-lock.json'), '\n'))
for name, plugin in pairs(require('lazy.core.config').plugins) do
    local pin = assert(lockfile[name], 'plugin missing from lockfile: ' .. name)
    local result = vim.system({ 'git', '-C', plugin.dir, 'rev-parse', 'HEAD' }, { text = true }):wait()
    assert(result.code == 0, 'plugin is not installed: ' .. name)
    assert_equal(vim.trim(result.stdout), pin.commit, 'plugin revision drift: ' .. name)
end

-- Detect missing parser builds that would otherwise surface only when opening notes.
local norg_buffer = vim.api.nvim_create_buf(false, true)
vim.api.nvim_buf_set_lines(norg_buffer, 0, -1, false, { '* A pinned-parser note', 'Content' })
local parser = vim.treesitter.get_parser(norg_buffer, 'norg')
assert(#parser:parse() > 0, 'locked Norg parser did not load')
vim.api.nvim_buf_delete(norg_buffer, { force = true })

for name, version in pairs(tools_by_name) do
    local path = vim.fn.stdpath('data') .. '/mason/packages/' .. name .. '/mason-receipt.json'
    assert(vim.fn.filereadable(path) == 1, 'missing pinned tool ' .. name .. '; run task setup')
    local receipt = vim.json.decode(table.concat(vim.fn.readfile(path), '\n'))
    assert_equal(receipt.source.id:match('@([^?]+)'), version, 'tool version drift: ' .. name)
end

local mode = vim.env.NVIM_TEST_MODE
if mode == 'lsp' or mode == 'install' then
    -- This exact version is only a deterministic integration-test fixture.
    local test_ty_version = '0.0.84'
    local package = registry.get_package('ty')
    for _, name in ipairs(mode == 'install' and { 'ty', 'black', 'ruff' } or {}) do
        local tool = registry.get_package(name)
        if tool:is_installed() then
            local removed = false
            tool:uninstall({}, function(success)
                assert(success, 'could not reset sandbox ' .. name .. ' installation')
                removed = true
            end)
            wait_until(function()
                return removed
            end, 30000, 'sandbox ' .. name .. ' uninstall timed out')
        end
    end
    local original_refresh = registry.refresh
    local original_notify = vim.notify
    local install_failures = {}
    if mode == 'lsp' then
        registry.refresh = function()
            error('installed tools must activate without a registry refresh')
        end
    else
        -- Inject a registry outage at the I/O boundary, then retry using real Mason.
        registry.refresh = function(callback)
            callback(false)
        end
        vim.notify = function(message, level, options)
            if tostring(message):find('Mason registry refresh failed', 1, true) then
                install_failures[#install_failures + 1] = message
                return
            end
            return original_notify(message, level, options)
        end
    end
    local fixture_dir = vim.fn.tempname()
    vim.fn.mkdir(fixture_dir, 'p')
    local fixture = fixture_dir .. '/type_error.py'
    vim.fn.writefile({ 'def answer() -> int:', '    return "wrong"', '', 'value = answer()' }, fixture)
    vim.fn.writefile({ '[project]', 'name = "nvim-test"', 'version = "0.0.0"' }, fixture_dir .. '/pyproject.toml')
    vim.cmd.edit(fixture)
    vim.bo.filetype = 'python'
    if mode == 'install' then
        wait_until(function()
            return #install_failures == 2
        end, 10000, 'registry failure did not report both Python formatter failures')
        assert_equal(requests, {}, 'registry failure must not start package installs')
        registry.refresh = original_refresh
        vim.notify = original_notify
    end
    vim.api.nvim_exec_autocmds('FileType', { buffer = 0 })
    vim.api.nvim_exec_autocmds('FileType', { buffer = 0 })

    wait_until(function()
        return registry.get_package('black'):get_installed_version() == tools_by_name.black
            and registry.get_package('ruff'):get_installed_version() == tools_by_name.ruff
            and not registry.get_package('black'):is_installing()
            and not registry.get_package('ruff'):is_installing()
    end, 120000, 'pinned Python formatters did not install on first use')
    table.sort(requests)
    assert_equal(requests, mode == 'install' and { 'black', 'ruff' } or {}, 'filetype installation requests must include formatters only')
    registry.refresh = original_refresh

    if mode == 'install' then
        local server_install_success, server_install_error
        package:install(
            { version = test_ty_version },
            vim.schedule_wrap(function(success, err)
                server_install_success, server_install_error = success, err
            end)
        )
        wait_until(function()
            return server_install_success ~= nil
        end, 120000, 'manual Mason installation of the Ty test server timed out')
        assert(server_install_success, 'manual Ty installation failed: ' .. tostring(server_install_error))
    else
        assert_equal(package:get_installed_version(), test_ty_version, 'Ty test fixture version drift')
    end
    wait_until(function()
        return vim.lsp.is_enabled('ty') and #vim.lsp.get_clients({ bufnr = 0, name = 'ty' }) == 1
    end, 120000, 'Mason-installed ty did not enable and attach to the Python fixture')
    table.sort(requests)
    assert_equal(requests, mode == 'install' and { 'black', 'ruff', 'ty' } or {}, 'only explicit server installation may request an LSP package')

    wait_until(function()
        for _, diagnostic in ipairs(vim.diagnostic.get(0)) do
            if diagnostic.code == 'invalid-return-type' and diagnostic.lnum == 1 then
                return true
            end
        end
        return false
    end, 30000, 'ty did not report the intentional Python type error')

    local client = vim.lsp.get_clients({ bufnr = 0, name = 'ty' })[1]
    local attached_servers = vim.tbl_map(function(attached_client)
        return attached_client.name
    end, vim.lsp.get_clients({ bufnr = 0 }))
    local expected_servers = {}
    for _, name in ipairs(require('mason-lspconfig').get_installed_servers()) do
        if vim.list_contains(vim.lsp.config[name].filetypes or {}, 'python') then
            expected_servers[#expected_servers + 1] = name
        end
    end
    table.sort(attached_servers)
    table.sort(expected_servers)
    assert_equal(attached_servers, expected_servers, 'all installed Python LSPs must attach')
    assert(client:supports_method('textDocument/inlayHint'), 'pinned ty must support inlay hints')
    local mapping = vim.fn.maparg('<leader>uh', 'n', false, true)
    assert(mapping.callback, 'inlay hint mapping missing after real LspAttach')
    local other_buffer = vim.api.nvim_create_buf(false, true)
    mapping.callback()
    assert(vim.lsp.inlay_hint.is_enabled({ bufnr = vim.api.nvim_get_current_buf() }), 'toggle did not enable hints')
    assert(not vim.lsp.inlay_hint.is_enabled({ bufnr = other_buffer }), 'toggle leaked to another buffer')
    mapping.callback()
    if mode ~= 'install' then
        client:stop(true)
    end

    -- Exercise the configured Python formatter pipeline with real Black and Ruff.
    vim.api.nvim_buf_set_lines(0, 0, -1, false, { 'result= {"answer":42}' })
    local format_error
    require('conform').format({ async = false, timeout_ms = 10000 }, function(err)
        format_error = err
    end)
    assert(format_error == nil, 'Python formatters failed: ' .. tostring(format_error))
    assert_equal(vim.api.nvim_buf_get_lines(0, 0, -1, false), { 'result = {"answer": 42}' }, 'Python formatting regression')
    if mode == 'install' then
        -- Uninstall after the installer has marked a formatter usable, then reopen.
        local black = registry.get_package('black')
        local removed = false
        black:uninstall({}, function(success)
            assert(success, 'Black uninstall failed')
            removed = true
        end)
        wait_until(function()
            return removed
        end, 30000, 'Black uninstall timed out')
        vim.api.nvim_exec_autocmds('FileType', { buffer = 0 })
        wait_until(function()
            return black:get_installed_version() == tools_by_name.black and not black:is_installing()
        end, 120000, 'reopening Python did not reinstall Black')

        local server_removed = false
        package:uninstall({}, function(success)
            assert(success, 'ty uninstall failed')
            server_removed = true
        end)
        wait_until(function()
            return server_removed and not vim.lsp.is_enabled('ty') and #vim.lsp.get_clients({ bufnr = 0, name = 'ty' }) == 0
        end, 30000, 'uninstalling ty did not invalidate LSP activation')
        vim.api.nvim_exec_autocmds('FileType', { buffer = 0 })
        vim.wait(100, function()
            return false
        end)
        assert(not package:is_installed(), 'opening a Python file must not reinstall an uninstalled LSP')
        assert(not vim.lsp.is_enabled('ty'), 'uninstalled LSP must remain disabled')

        local reinstall_success, reinstall_error
        package:install(
            { version = test_ty_version },
            vim.schedule_wrap(function(success, err)
                reinstall_success, reinstall_error = success, err
            end)
        )
        wait_until(function()
            return reinstall_success ~= nil
        end, 120000, 'manual Mason reinstall of Ty timed out')
        assert(reinstall_success, 'manual Ty reinstall failed: ' .. tostring(reinstall_error))
        wait_until(function()
            return package:get_installed_version() == test_ty_version and vim.lsp.is_enabled('ty') and #vim.lsp.get_clients({ bufnr = 0, name = 'ty' }) == 1
        end, 120000, 'manually reinstalled Ty did not reactivate')
        vim.lsp.get_clients({ bufnr = 0, name = 'ty' })[1]:stop(true)
    end
    vim.fn.delete(fixture_dir, 'rf')
end

-- Run the same journal command used by the keymap inside the sandbox workspace.
vim.cmd('Neorg workspace default')
vim.cmd('Neorg journal today')
local journal_path = vim.api.nvim_buf_get_name(0)
assert(journal_path:find(vim.env.NVIM_TEST_WORKSPACE .. '/journal/', 1, true) == 1, 'journal escaped test workspace')
vim.cmd.write()
assert(vim.fn.filereadable(journal_path) == 1, 'journal command did not create an entry')

print('Neovim configuration checks passed')
