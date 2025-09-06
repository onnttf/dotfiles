local default_opts = {
	noremap = true,
	silent = true,
}

local function keymap(mode, lhs, rhs, opts)
	if not (mode and lhs and rhs) then
		vim.notify("Invalid keymap: 'mode', 'lhs', and 'rhs' are required.", vim.log.levels.ERROR)
		return
	end

	opts = vim.tbl_extend("force", default_opts, opts or {})

	vim.keymap.set(mode, lhs, rhs, opts)
end

local wk = require("which-key")

keymap("n", "<Esc>", "<cmd>nohlsearch<CR><cmd>let @/ = ''<CR>", {
	desc = "Search: Clear highlights & register",
})

keymap("n", "<C-h>", "<C-w>h", { desc = "Window: Focus left" })
keymap("n", "<C-j>", "<C-w>j", { desc = "Window: Focus down" })
keymap("n", "<C-k>", "<C-w>k", { desc = "Window: Focus up" })
keymap("n", "<C-l>", "<C-w>l", { desc = "Window: Focus right" })

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

keymap("n", "0", "^", { desc = "Go to: First non-blank char" })
keymap("n", "$", "g_", { desc = "Go to: Last non-blank char" })

keymap("v", "p", '"_d"+p', { desc = "Paste: Preserve default register" })
keymap("v", "P", '"_d"+P', { desc = "Paste: Preserve default register" })
