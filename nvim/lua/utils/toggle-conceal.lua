return function()
    if vim.o.conceallevel ~= 0 then
        vim.o.conceallevel = 0
    else
        vim.o.conceallevel = 2
    end
    print('Toggled conceal level to', vim.o.conceallevel)
end
