local keymap = require("util").keymap

keymap("n", "<Esc>", "<cmd>nohlsearch<CR><cmd>let @/ = ''<CR>", {
	desc = "Clear search highlights and reset search register",
})

keymap("n", "<C-h>", "<C-w>h", { desc = "Focus left window" })
keymap("n", "<C-j>", "<C-w>j", { desc = "Focus lower window" })
keymap("n", "<C-k>", "<C-w>k", { desc = "Focus upper window" })
keymap("n", "<C-l>", "<C-w>l", { desc = "Focus right window" })

keymap("n", "j", "v:count == 0 ? 'gj' : 'j'", {
	expr = true,
	silent = true,
	noremap = true,
	desc = "Move down, respecting wrapped lines",
})
keymap("n", "k", "v:count == 0 ? 'gk' : 'k'", {
	expr = true,
	silent = true,
	noremap = true,
	desc = "Move up, respecting wrapped lines",
})

keymap("v", "p", '"_d"+p', { desc = "Paste without overwriting default register" })
keymap("v", "P", '"_d"+P', { desc = "Paste without overwriting default register" })
