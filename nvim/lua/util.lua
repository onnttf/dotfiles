-- Default options for key mappings
local default_opts = {
    noremap = true, -- Prevent recursive mappings
    silent = true -- Suppress output of commands
}

-- Utility function to create key mappings with default options
-- @param mode (string|table): The mode(s) in which the keymap applies (e.g., "n", "i", "v", etc.)
-- @param lhs (string): The left-hand side of the keymap (key combination)
-- @param rhs (string|function): The right-hand side of the keymap (command or Lua function)
-- @param opts (table|nil): Additional options to override the defaults
local function keymap(mode, lhs, rhs, opts)
    if not (mode and lhs and rhs) then
        vim.notify("Invalid keymap: mode, lhs, and rhs are required", vim.log.levels.ERROR)
        return
    end

    opts = opts or {}
    opts = vim.tbl_extend("force", default_opts, opts)

    vim.keymap.set(mode, lhs, rhs, opts)
end

return {
    keymap = keymap
}
