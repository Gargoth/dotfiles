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

local servers = dofile(config_dir .. '/lua/lsp/servers.lua')
local enabled_names = vim.tbl_map(function(server)
    return server.name
end, servers)
if vim.list_contains(enabled_names, 'basedpyright') then
    fail('BasedPyright must not be in the configured server list')
end
if vim.list_contains(enabled_names, 'tree-sitter-cli') then
    fail('tree-sitter-cli must not be configured as a language server')
end
if not vim.list_contains(enabled_names, 'ty') then
    fail('ty must be in the explicit server list')
end

local ty_config = assert(vim.lsp.config.ty, 'ty did not resolve from native configuration')
if ty_config.settings.ty.diagnosticMode ~= 'workspace' then
    fail('ty must resolve with workspace diagnostics enabled')
end

local vtsls_config = assert(vim.lsp.config.vtsls, 'vtsls did not resolve from native configuration')
if not vim.list_contains(vtsls_config.filetypes, 'vue') or not vim.list_contains(vtsls_config.filetypes, 'svelte') then
    fail('vtsls must attach to Vue and Svelte files')
end
local vue_plugin = vtsls_config.settings.vtsls.tsserver.globalPlugins[1]
if vue_plugin.name ~= '@vue/typescript-plugin' or not vim.list_contains(vue_plugin.languages, 'vue') then
    fail('vtsls must load the Vue TypeScript plugin for Vue files')
end

local mason_config = read_lua_module('plugins.mason-lspconfig-nvim').opts
assert_equal(mason_config.automatic_enable, false, 'Mason must not enable unspecified servers')

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
vim.bo[buffer].filetype = 'javascript'
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
table.sort(actual_enabled)
table.sort(enabled_names)
assert_equal(actual_enabled, enabled_names, 'only explicitly selected servers should be enabled')
for _, name in ipairs(enabled_names) do
    local config = vim.lsp.config[name]
    assert(config.cmd and config.filetypes, 'missing executable or filetypes for ' .. name)
end

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

local mapping = require('mason-lspconfig').get_mappings().lspconfig_to_package
for name, version in pairs(tools_by_name) do
    local package_name = mapping[name] or name
    local path = vim.fn.stdpath('data') .. '/mason/packages/' .. package_name .. '/mason-receipt.json'
    assert(vim.fn.filereadable(path) == 1, 'missing pinned tool ' .. name .. '; run task setup')
    local receipt = vim.json.decode(table.concat(vim.fn.readfile(path), '\n'))
    assert_equal(receipt.source.id:match('@([^?]+)'), version, 'tool version drift: ' .. name)
end

if vim.env.NVIM_TEST_MODE == 'lsp' then
    local fixture_dir = vim.fn.tempname()
    vim.fn.mkdir(fixture_dir, 'p')
    local fixture = fixture_dir .. '/type_error.py'
    vim.fn.writefile({ 'def answer() -> int:', '    return "wrong"', '', 'value = answer()' }, fixture)
    vim.fn.writefile({ '[project]', 'name = "nvim-test"', 'version = "0.0.0"' }, fixture_dir .. '/pyproject.toml')
    vim.cmd.edit(fixture)
    vim.bo.filetype = 'python'

    wait_until(function()
        return #vim.lsp.get_clients({ bufnr = 0, name = 'ty' }) == 1
    end, 20000, 'configured ty did not automatically attach to the Python fixture')

    wait_until(function()
        for _, diagnostic in ipairs(vim.diagnostic.get(0)) do
            if diagnostic.code == 'invalid-return-type' and diagnostic.lnum == 1 then
                return true
            end
        end
        return false
    end, 30000, 'ty did not report the intentional Python type error')

    local client = vim.lsp.get_clients({ bufnr = 0, name = 'ty' })[1]
    assert_equal(#vim.lsp.get_clients({ bufnr = 0 }), 1, 'only ty should attach to Python')
    assert(client:supports_method('textDocument/inlayHint'), 'pinned ty must support inlay hints')
    local mapping = vim.fn.maparg('<leader>uh', 'n', false, true)
    assert(mapping.callback, 'inlay hint mapping missing after real LspAttach')
    local other_buffer = vim.api.nvim_create_buf(false, true)
    mapping.callback()
    assert(vim.lsp.inlay_hint.is_enabled({ bufnr = vim.api.nvim_get_current_buf() }), 'toggle did not enable hints')
    assert(not vim.lsp.inlay_hint.is_enabled({ bufnr = other_buffer }), 'toggle leaked to another buffer')
    mapping.callback()
    client:stop(true)

    -- Exercise the configured Python formatter pipeline with real Black and Ruff.
    vim.api.nvim_buf_set_lines(0, 0, -1, false, { 'result= {"answer":42}' })
    local format_error
    require('conform').format({ async = false, timeout_ms = 10000 }, function(err)
        format_error = err
    end)
    assert(format_error == nil, 'Python formatters failed: ' .. tostring(format_error))
    assert_equal(vim.api.nvim_buf_get_lines(0, 0, -1, false), { 'result = {"answer": 42}' }, 'Python formatting regression')
    vim.fn.delete(fixture_dir, 'rf')
end

print('Neovim configuration checks passed')
