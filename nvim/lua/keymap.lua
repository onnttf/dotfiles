-- [[ Keymap ]]
local keymap = require("util").keymap

-- Map <Esc> in normal mode to clear search highlights and reset the search register
keymap("n", "<Esc>", "<cmd>nohlsearch<CR><cmd>let @/ = ''<CR>", {
    desc = "Clear search highlights and reset search register"
})

-- Window navigation key mappings in normal mode
keymap("n", "<C-h>", "<C-w>h", {
    desc = "Focus left window"
})
keymap("n", "<C-j>", "<C-w>j", {
    desc = "Focus lower window"
})
keymap("n", "<C-k>", "<C-w>k", {
    desc = "Focus upper window"
})
keymap("n", "<C-l>", "<C-w>l", {
    desc = "Focus right window"
})

-- Remap 'k' and 'j' to handle wrapped lines properly
keymap("n", "k", "v:count == 0 ? 'gk' : 'k'", {
    expr = true,
    silent = true,
    desc = "Move up, respecting wrapped lines"
})
keymap("n", "j", "v:count == 0 ? 'gj' : 'j'", {
    expr = true,
    silent = true,
    desc = "Move down, respecting wrapped lines"
})

-- In visual mode, remap 'p' so that pasting does not overwrite the default register
keymap("v", "p", '"_d"+p', {
    desc = "Paste without overwriting default register"
})
