-- [[ Keymap ]]
local keymap = require("util").keymap

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
