local M = {}

local function isEmpty(data)
    return data == nil or next(data) == nil
end

function M.isEmpty(data)
    return isEmpty(data)
end

function M.keymap(mode, lhs, rhs, opts)
    if lhs == '' then
        return
    end
    opts = opts or {
        noremap = true,
        silent = true,
        desc = "desc"
    }
    vim.keymap.set(mode, lhs, rhs, opts)
end

return M
