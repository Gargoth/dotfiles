function nvimformat
    git ls-files -z | xargs -0 -I {} nvim --headless -n -c "lua require('conform').format({ async = false, lsp_fallback = true }); vim.cmd('w'); vim.cmd('q')" {}
end
