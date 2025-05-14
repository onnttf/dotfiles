-- [[ Keymap ]]
local keymap = require("util").keymap
local wk = require("which-key")

-- Map <Esc> in normal mode to clear search highlights and reset the search register
keymap("n", "<Esc>", "<cmd>nohlsearch<CR><cmd>let @/ = ''<CR>", {
	desc = "Clear search highlights and reset search register",
})

-- Window navigation key mappings in normal mode
keymap("n", "<C-h>", "<C-w>h", {
	desc = "Focus left window",
})
keymap("n", "<C-j>", "<C-w>j", {
	desc = "Focus lower window",
})
keymap("n", "<C-k>", "<C-w>k", {
	desc = "Focus upper window",
})
keymap("n", "<C-l>", "<C-w>l", {
	desc = "Focus right window",
})

-- Remap 'j' and 'k' to handle wrapped lines properly
keymap("n", "j", "v:count == 0 ? 'gj' : 'j'", {
	expr = true,
	silent = true,
	desc = "Move down, respecting wrapped lines",
})
keymap("n", "k", "v:count == 0 ? 'gk' : 'k'", {
	expr = true,
	silent = true,
	desc = "Move up, respecting wrapped lines",
})

-- Remap 'p' and 'P' in visual mode to prevent pasting from overwriting the default register.
keymap("v", "p", '"_d"+p', {
	desc = "Paste without overwriting default register",
})
keymap("v", "P", '"_d"+P', {
	desc = "Paste without overwriting default register",
})

-- Copies the diagnostic message under the cursor to the clipboard in normal mode.
keymap("n", "<leader>cd", function()
	local diagnostics =
		vim.diagnostic.get(vim.api.nvim_get_current_buf(), { lnum = vim.api.nvim_win_get_cursor(0)[1] - 1 })
	if #diagnostics > 0 then
		local messages = {}
		for _, diag in ipairs(diagnostics) do
			table.insert(messages, diag.message)
		end
		vim.fn.setreg("+", table.concat(messages, "\n"))
		vim.notify("Diagnostic message copied to clipboard", vim.log.levels.INFO)
	else
		vim.notify("No diagnostic found on this line", vim.log.levels.WARN)
	end
end, {
	desc = "[C]opy diagnostic message under cursor",
})
wk.add({ {
	"<leader>c",
	desc = "[C]opy-related keymaps",
} })