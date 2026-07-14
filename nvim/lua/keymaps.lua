-- [[ Basic Keymaps ]]

-- Clear highlights on pressing <Esc> in normal mode
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Toggle alternate file
vim.keymap.set('n', '<leader>`', '<C-6>', { desc = 'Go to previous (alternate) buffer' })

-- Yank Buffer
vim.keymap.set('n', '<leader>yy', ':%y+<CR>', { desc = 'Yank entire buffer to unnamed clipboard' })

-- Diagnostic keymaps
vim.keymap.set('n', '[d', function()
    vim.diagnostic.jump({ count = -1 })
end, { desc = 'Go to previous [D]iagnostic message' })
vim.keymap.set('n', ']d', function()
    vim.diagnostic.jump({ count = 1 })
end, { desc = 'Go to next [D]iagnostic message' })
vim.keymap.set('n', '<leader>ce', vim.diagnostic.open_float, { desc = 'Show [C]ode diagnostic [E]rror messages' })
vim.keymap.set('n', '<leader>cq', vim.diagnostic.setloclist, { desc = 'Open [C]ode diagnostic [Q]uickfix list' }) -- Technically loclist

-- [[ Quickfix ]]
vim.keymap.set('n', '<leader>q', require('utils.toggle-qf'), { desc = 'Toggle [q]uickfix list' })

-- Split navigation
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- Split Resizing
-- Resize with Alt + hjkl
vim.keymap.set('n', '<M-k>', ':resize -2<CR>', { silent = true })
vim.keymap.set('n', '<M-j>', ':resize +2<CR>', { silent = true })
vim.keymap.set('n', '<M-h>', ':vertical resize -2<CR>', { silent = true })
vim.keymap.set('n', '<M-l>', ':vertical resize +2<CR>', { silent = true })

-- [[ LSP Keymapping ]]
vim.keymap.set('n', '<leader>LI', ':checkhealth vim.lsp<CR>', { desc = '[L]sp [I]nfo' })
vim.keymap.set('n', '<leader>LR', ':lsp restart<CR>', { desc = '[L]sp [R]estart' })
vim.keymap.set('n', '<leader>LS', ':lsp stop<CR>', { desc = '[L]sp [S]top' })
vim.keymap.set('n', '<leader>LL', ':lua vim.cmd.edit(vim.lsp.get_log_path())<CR>', { desc = '[L]sp [L]og' })

-- [[ UI ]]
vim.keymap.set('n', '<leader>uc', require('utils.toggle-conceal'), { desc = 'Toggle [C]onceal between 0 and 2' })
vim.keymap.set('n', '<leader>uw', require('utils.toggle-wrap-linebreak'), { desc = 'Toggle [W]rap and Linebreak' })

-- [[ QoL ]]
vim.keymap.set('n', '<leader>md', ':set ft=markdown<CR>', { desc = 'Set filetype to [m]arkd[d]own' })
