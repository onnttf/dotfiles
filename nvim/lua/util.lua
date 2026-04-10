local M = {}

-- Thin wrapper around |vim.keymap.set()| with |noremap| and |silent| as defaults.
local default_opts = { noremap = true, silent = true }

function M.keymap(mode, lhs, rhs, opts)
	assert(mode and lhs and rhs, "keymap: mode, lhs, rhs are required")
	opts = vim.tbl_deep_extend("force", {}, default_opts, opts or {})
	vim.keymap.set(mode, lhs, rhs, opts)
end

return M
