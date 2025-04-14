-- Default options for key mappings
local default_opts = { noremap = true, silent = true }

-- Helper function to create key mappings with default options merged
local function keymap(mode, lhs, rhs, opts)
	opts = opts or {}
	opts = vim.tbl_extend("force", default_opts, opts)
	vim.keymap.set(mode, lhs, rhs, opts)
end

return {
	keymap = keymap,
}
