local errors = {}
local notify = vim.notify
vim.notify = function(message, level, options)
    if level == vim.log.levels.ERROR then
        errors[#errors + 1] = tostring(message)
    end
    return notify(message, level, options)
end

local ok, err = xpcall(function()
    dofile(vim.fn.stdpath('config') .. '/init.lua')
end, debug.traceback)
if not ok then
    io.stderr:write(err .. '\n')
    vim.cmd.cquit(1)
    return
end

vim.api.nvim_create_autocmd('VimEnter', {
    once = true,
    callback = function()
        vim.defer_fn(function()
            local success, failure = xpcall(function()
                assert(#errors == 0, table.concat(errors, '\n'))
                local mode = vim.env.NVIM_TEST_MODE
                if mode == 'restore' then
                    require('lazy').restore({ wait = true, show = false })
                    vim.cmd('MasonToolsInstallSync')
                    dofile(vim.fn.stdpath('config') .. '/tests/config_spec.lua')
                elseif mode == 'doctor' then
                    vim.cmd('checkhealth vim.lsp')
                    print(table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), '\n'))
                else
                    dofile(vim.fn.stdpath('config') .. '/tests/config_spec.lua')
                end
                assert(#errors == 0, table.concat(errors, '\n'))
            end, debug.traceback)
            if success then
                vim.cmd('qa!')
            else
                io.stderr:write(failure .. '\n')
                vim.cmd.cquit(1)
            end
        end, 300)
    end,
})
