local M = {}

M.servers = {}

function M.add(server)
    table.insert(M.servers, server)
end

return M
