for _, directory in ipairs({ 'lua', 'after', 'tests' }) do
    for _, file in ipairs(vim.fn.glob(directory .. '/**/*.lua', true, true)) do
        assert(loadfile(file))
    end
end
assert(loadfile('init.lua'))
print('Lua syntax checks passed')
