local M = {}

-- Function to create an autocommand group
function M.augroup(name)
	return vim.api.nvim_create_augroup("neovim_" .. name, {
		clear = true, -- Clear existing autocommands in the group
	})
end

-- Function to set key mappings
function M.keymap(mode, lhs, rhs, opts)
	-- If left-hand side is empty, return
	if lhs == "" then
		return
	end
	-- Set default options if not provided
	opts = opts
		or {
			noremap = true, -- Do not remap key
			silent = true, -- Do not show command in command-line
			desc = "desc", -- Description (just a placeholder, you may customize)
		}
	-- Set the key mapping
	vim.keymap.set(mode, lhs, rhs, opts)
end

return M
