-- Define a module named 'M'
local M = {}

-- Check if a table or string is empty
local function isEmpty(data)
    return data == nil or next(data) == nil
end

-- Expose the 'isEmpty' function in the module
function M.isEmpty(data)
    return isEmpty(data)
end

-- Define a key mapping with optional options
function M.keymap(mode, lhs, rhs, opts)
    -- Skip empty mappings
    if lhs == '' then
        return
    end

    -- Set default options if not provided
    opts = opts or {
        noremap = true,  -- Avoid recursive mapping
        silent = true,   -- Avoid displaying command in command-line
        desc = "desc"    -- Default description
    }

    -- Set the key mapping using 'vim.keymap.set'
    vim.keymap.set(mode, lhs, rhs, opts)
end

-- Export the module
return M
