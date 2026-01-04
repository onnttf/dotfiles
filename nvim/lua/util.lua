-- Utility functions for Neovim configuration

local M = {}

-- Default keymap options
local default_opts = {
	noremap = true,
	silent = true,
}

--- Create a keymap with default options and validation
--- @param mode string The mode(s) for the keymap (e.g. "n", "v", "i", "niv")
--- @param lhs string The left-hand side keys
--- @param rhs string|function The right-hand side mapping
--- @param opts table Optional options (desc, etc.)
function M.keymap(mode, lhs, rhs, opts)
	assert(mode and lhs and rhs, "keymap: mode, lhs, rhs are required")
	
	opts = vim.tbl_deep_extend("force", {}, default_opts, opts or {})
	
	if not opts.desc then
		vim.notify("Keymap missing desc: " .. lhs, vim.log.levels.WARN)
	end
	
	vim.keymap.set(mode, lhs, rhs, opts)
end

return M
