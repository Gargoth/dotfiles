-- Bootstrap lazy.nvim plugin manager

local source = debug.getinfo(1, 'S').source:sub(2)
local config_dir = vim.fn.fnamemodify(source, ':p:h:h')
local lockfile = vim.json.decode(table.concat(vim.fn.readfile(config_dir .. '/lazy-lock.json'), '\n'))
local lazy_commit = assert(lockfile['lazy.nvim'], 'lazy.nvim must be pinned in lazy-lock.json').commit
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'

if vim.fn.isdirectory(lazypath) == 0 then
    assert(vim.env.NVIM_TEST_MODE == nil or vim.env.NVIM_TEST_MODE == 'restore', 'verification dependencies missing; run task setup')
    local parent = vim.fn.fnamemodify(lazypath, ':h')
    assert(vim.fn.mkdir(parent, 'p') == 1 or vim.fn.isdirectory(parent) == 1, 'failed to create lazy.nvim parent directory')
    local staging_path = lazypath .. '.tmp-' .. vim.fn.getpid()
    vim.fn.delete(staging_path, 'rf')
    vim.fn.system({ 'git', 'clone', '--filter=blob:none', 'https://github.com/folke/lazy.nvim.git', staging_path })
    if vim.v.shell_error ~= 0 then
        vim.fn.delete(staging_path, 'rf')
        error('failed to clone lazy.nvim')
    end
    vim.fn.system({ 'git', '-C', staging_path, 'checkout', '--detach', lazy_commit })
    if vim.v.shell_error ~= 0 then
        vim.fn.delete(staging_path, 'rf')
        error('failed to check out pinned lazy.nvim commit')
    end
    if vim.fn.rename(staging_path, lazypath) ~= 0 then
        vim.fn.delete(staging_path, 'rf')
        error('failed to install lazy.nvim checkout')
    end
end

vim.opt.rtp:prepend(lazypath)

-- Set keybind for lazy.nvim
vim.keymap.set('n', '<leader>l', ':Lazy<CR>', { desc = 'Toggle Lazy' })
