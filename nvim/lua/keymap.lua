-- Key mappings for Neovim configuration

local keymap = require("util").keymap

-- Search
keymap("n", "<Esc>", "<cmd>nohlsearch<CR><cmd>let @/ = ''<CR>", {
	desc = "Clear search",
})

-- Window navigation
keymap("n", "<C-h>", "<C-w>h", { desc = "Focus left" })
keymap("n", "<C-j>", "<C-w>j", { desc = "Focus down" })
keymap("n", "<C-k>", "<C-w>k", { desc = "Focus up" })
keymap("n", "<C-l>", "<C-w>l", { desc = "Focus right" })

-- Movement (wrap-aware)
keymap("n", "j", "v:count == 0 ? 'gj' : 'j'", {
	expr = true,
	desc = "Move down",
})
keymap("n", "k", "v:count == 0 ? 'gk' : 'k'", {
	expr = true,
	desc = "Move up",
})

-- Line navigation
keymap("n", "0", "^", { desc = "Go to first non-blank" })
keymap("n", "$", "g_", { desc = "Go to last non-blank" })

-- Paste without overwriting clipboard
keymap("v", "p", '"_d"+p', { desc = "Paste" })
keymap("v", "P", '"_d"+P', { desc = "Paste" })
