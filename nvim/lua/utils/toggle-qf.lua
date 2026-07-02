return function()
    local windows = vim.fn.getwininfo()
    for _, win in pairs(windows) do
        if win['quickfix'] == 1 then
            vim.cmd.cclose()
            return
        end
    end
    vim.cmd.copen()
end
