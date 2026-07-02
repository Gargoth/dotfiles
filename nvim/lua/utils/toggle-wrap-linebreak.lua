return function()
    if vim.o.wrap then
        vim.o.wrap = false
        vim.o.linebreak = false
    else
        vim.o.wrap = true
        vim.o.linebreak = true
    end
    print('Toggled text wrapping to', vim.o.wrap)
end
