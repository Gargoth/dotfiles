-- Bootstrap lazy.nvim plugin manager

local source = debug.getinfo(1, 'S').source:sub(2)
local config_dir = vim.fn.fnamemodify(source, ':p:h:h')
local lockfile = vim.json.decode(table.concat(vim.fn.readfile(config_dir .. '/lazy-lock.json'), '\n'))
local lazy_commit = assert(lockfile['lazy.nvim'], 'lazy.nvim must be pinned in lazy-lock.json').commit
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'

if vim.fn.isdirectory(lazypath) == 0 then
    assert(vim.env.NVIM_TEST_MODE == nil or vim.env.NVIM_TEST_MODE == 'restore', 'verification dependencies missing; run task setup')
    vim.fn.mkdir(vim.fn.fnamemodify(lazypath, ':h'), 'p')
    vim.fn.system({ 'git', 'clone', '--filter=blob:none', 'https://github.com/folke/lazy.nvim.git', lazypath })
    assert(vim.v.shell_error == 0, 'failed to clone lazy.nvim')
    vim.fn.system({ 'git', '-C', lazypath, 'checkout', '--detach', lazy_commit })
    assert(vim.v.shell_error == 0, 'failed to check out pinned lazy.nvim commit')
end

vim.opt.rtp:prepend(lazypath)

-- Set keybind for lazy.nvim
vim.keymap.set('n', '<leader>l', ':Lazy<CR>', { desc = 'Toggle Lazy' })
