-- [[ Keymap ]]

-- Default options for key mappings.
local default_opts = {
	noremap = true, -- Prevent recursive mappings.
	silent = true, -- Suppress command output.
}

--- Utility function to create Neovim key mappings with sensible defaults.
--- @param mode (string|table): The mode(s) in which the keymap applies (e.g., "n", "i", "v").
--- @param lhs (string): The left-hand side of the keymap.
--- @param rhs (string|function): The right-hand side of the keymap.
--- @param opts (table|nil): Optional additional options.
local function keymap(mode, lhs, rhs, opts)
	-- Validate required arguments.
	if not (mode and lhs and rhs) then
		vim.notify("Invalid keymap: 'mode', 'lhs', and 'rhs' are required.", vim.log.levels.ERROR)
		return
	end

	-- Extend default options with any provided custom options.
	opts = vim.tbl_extend("force", default_opts, opts or {})

	-- Set the keymap using Neovim's built-in API.
	vim.keymap.set(mode, lhs, rhs, opts)
end

-- Require which-key for displaying keybindings.
local wk = require("which-key")

-- Clear search highlights and reset search register.
keymap("n", "<Esc>", "<cmd>nohlsearch<CR><cmd>let @/ = ''<CR>", {
	desc = "Search: Clear highlights & register",
})

-- Window navigation key mappings.
keymap("n", "<C-h>", "<C-w>h", { desc = "Window: Focus left" })
keymap("n", "<C-j>", "<C-w>j", { desc = "Window: Focus down" })
keymap("n", "<C-k>", "<C-w>k", { desc = "Window: Focus up" })
keymap("n", "<C-l>", "<C-w>l", { desc = "Window: Focus right" })

-- Remap 'j' and 'k' to handle wrapped lines properly.
keymap("n", "j", "v:count == 0 ? 'gj' : 'j'", {
	expr = true,
	silent = true,
	desc = "Move: Down (respect wrapped lines)",
})
keymap("n", "k", "v:count == 0 ? 'gk' : 'k'", {
	expr = true,
	silent = true,
	desc = "Move: Up (respect wrapped lines)",
})

-- Go to line start/end, excluding leading/trailing whitespace.
keymap("n", "0", "^", { desc = "Go to: First non-blank char" })
keymap("n", "$", "g_", { desc = "Go to: Last non-blank char" })

-- Paste without overwriting the default register.
keymap("v", "p", '"_d"+p', { desc = "Paste: Preserve default register" })
keymap("v", "P", '"_d"+P', { desc = "Paste: Preserve default register" })

-- Copy diagnostic message under cursor to clipboard.
keymap("n", "<leader>cd", function()
	-- Get diagnostics for the current line.
	local diagnostics = vim.diagnostic.get(0, { lnum = vim.api.nvim_win_get_cursor(0)[1] - 1 })

	if #diagnostics > 0 then
		-- Extract only messages and join them with newlines.
		local messages = vim.tbl_map(function(diag)
			return diag.message
		end, diagnostics)
		vim.fn.setreg("+", table.concat(messages, "\n"))
		vim.notify("Diagnostic message copied.", vim.log.levels.INFO)
	else
		vim.notify("No diagnostic found on this line.", vim.log.levels.WARN)
	end
end, {
	desc = "Copy: Diagnostic message",
})

-- Which-key group for copy-related actions.
wk.add({
	{ "<leader>c", desc = "[C]opy actions", mode = { "n" } },
})
