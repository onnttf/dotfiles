-- Default options for key mappings: prevent recursive mappings and suppress command output.
local default_opts = {
	noremap = true,
	silent = true,
}

--- Utility function to create Neovim key mappings with sensible defaults.
--- @param mode (string|table): The mode(s) in which the keymap applies (e.g., "n", "i", "v", {"n", "v"}).
--- @param lhs (string): The left-hand side of the keymap (the key combination to press).
--- @param rhs (string|function): The right-hand side of the keymap (the command string or Lua function to execute).
--- @param opts (table|nil): Optional additional options to override or extend the defaults.
local function keymap(mode, lhs, rhs, opts)
	-- Validate required arguments to prevent errors.
	if not (mode and lhs and rhs) then
		vim.notify("Invalid keymap: 'mode', 'lhs', and 'rhs' are required.", vim.log.levels.ERROR)
		return
	end

	-- Extend default options with any provided custom options.
	-- `vim.tbl_extend("force", ...)` ensures custom options override defaults.
	opts = vim.tbl_extend("force", default_opts, opts or {})

	-- Set the keymap using Neovim's built-in API.
	vim.keymap.set(mode, lhs, rhs, opts)
end

return {
	keymap = keymap,
}
