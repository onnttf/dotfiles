local keymap = require("util").keymap

-- <Esc>: clear search highlight and pattern register (:h nohlsearch, :h @/)
keymap("n", "<Esc>", "<cmd>nohlsearch<CR><cmd>let @/ = ''<CR>", {
	desc = "Clear search",
})

-- j/k: use gj/gk when no count is given to move by visual lines (:h gj)
keymap("n", "j", "v:count == 0 ? 'gj' : 'j'", {
	expr = true,
	desc = "Move down",
})
keymap("n", "k", "v:count == 0 ? 'gk' : 'k'", {
	expr = true,
	desc = "Move up",
})

-- 0/$: jump to first/last non-blank character on line (:h ^ :h g_)
keymap("n", "0", "^", { desc = "Go to first non-blank" })
keymap("n", "$", "g_", { desc = "Go to last non-blank" })

-- p/P in visual: delete selection to black-hole, paste from system clipboard (:h quote_)
keymap("v", "p", '"_d"+p', { desc = "Paste" })
keymap("v", "P", '"_d"+P', { desc = "Paste" })

-- x/X/d/D/dd: send deleted text to black-hole register to preserve yank (:h quote_)
keymap("n", "x", '"_x', { desc = "Delete char without yank" })
keymap("n", "X", '"_X', { desc = "Delete before cursor without yank" })
keymap("v", "d", '"d', { desc = "Delete without yank" })
keymap("v", "D", '"D', { desc = "Delete line without yank" })
keymap("n", "dd", '"_dd', { desc = "Delete line without yank" })
