-- Load 'utils' module here
local utils = require("utils.utils")

-- Key mappings for common tasks

-- Search word under cursor
utils.keymap({ "n", "x" }, "ws", "*N", {
    desc = "Search word under cursor"
})

-- Clear search with <Esc>
utils.keymap({ "i", "n" }, "<esc>", "<cmd>noh<cr><esc>", {
    desc = "Escape and clear hlsearch"
})

-- Improved behavior for 'n' and 'N'
-- See: https://github.com/mhinz/vim-galore#saner-behavior-of-n-and-n
utils.keymap({ "n", "x", "o" }, "n", "'Nn'[v:searchforward]", {
    expr = true,
    desc = "Next search result"
})
utils.keymap({ "n", "x", "o" }, "N", "'nN'[v:searchforward]", {
    expr = true,
    desc = "Prev search result"
})

-- Better up/down movement
utils.keymap("n", "j", "v:count == 0 ? 'gj' : 'j'", {
    expr = true,
    silent = true,
    desc = "Smart down movement"
})
utils.keymap("n", "k", "v:count == 0 ? 'gk' : 'k'", {
    expr = true,
    silent = true,
    desc = "Smart up movement"
})

-- Move between windows using <Ctrl> hjkl keys
utils.keymap("n", "<C-h>", "<C-w>h", {
    desc = "Go to left window"
})
utils.keymap("n", "<C-j>", "<C-w>j", {
    desc = "Go to lower window"
})
utils.keymap("n", "<C-k>", "<C-w>k", {
    desc = "Go to upper window"
})
utils.keymap("n", "<C-l>", "<C-w>l", {
    desc = "Go to right window"
})

-- Move lines up and down
utils.keymap("n", "<A-j>", ":m .+1<cr>==", {
    desc = "Move down"
})
utils.keymap("v", "<A-j>", ":m '>+1<cr>gv=gv", {
    desc = "Move down"
})
utils.keymap("i", "<A-j>", "<Esc>:m .+1<cr>==gi", {
    desc = "Move down"
})
utils.keymap("n", "<A-k>", ":m .-2<cr>==", {
    desc = "Move up"
})
utils.keymap("v", "<A-k>", ":m '<-2<cr>gv=gv", {
    desc = "Move up"
})
utils.keymap("i", "<A-k>", "<Esc>:m .-2<cr>==gi", {
    desc = "Move up"
})
