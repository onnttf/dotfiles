local util = require("util")

util.keymap({ "i", "n" }, "<esc>", "<cmd>noh<cr><esc>")

util.keymap("n", "[d", vim.diagnostic.goto_prev, {
	desc = "Go to previous [D]iagnostic message",
})
util.keymap("n", "]d", vim.diagnostic.goto_next, {
	desc = "Go to next [D]iagnostic message",
})
util.keymap("n", "<leader>e", vim.diagnostic.open_float, {
	desc = "Show diagnostic [E]rror messages",
})
util.keymap("n", "<leader>q", vim.diagnostic.setloclist, {
	desc = "Open diagnostic [Q]uickfix list",
})

util.keymap("t", "<Esc><Esc>", "<C-\\><C-n>", {
	desc = "Exit terminal mode",
})

util.keymap("n", "<left>", '<cmd>echo "Use h to move!!"<CR>')
util.keymap("n", "<right>", '<cmd>echo "Use l to move!!"<CR>')
util.keymap("n", "<up>", '<cmd>echo "Use k to move!!"<CR>')
util.keymap("n", "<down>", '<cmd>echo "Use j to move!!"<CR>')

util.keymap("n", "<C-h>", "<C-w><C-h>", {
	desc = "Move focus to the left window",
})
util.keymap("n", "<C-l>", "<C-w><C-l>", {
	desc = "Move focus to the right window",
})
util.keymap("n", "<C-j>", "<C-w><C-j>", {
	desc = "Move focus to the lower window",
})
util.keymap("n", "<C-k>", "<C-w><C-k>", {
	desc = "Move focus to the upper window",
})

util.keymap({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", {
	expr = true,
	silent = true,
})
util.keymap({ "n", "x" }, "<Down>", "v:count == 0 ? 'gj' : 'j'", {
	expr = true,
	silent = true,
})
util.keymap({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", {
	expr = true,
	silent = true,
})
util.keymap({ "n", "x" }, "<Up>", "v:count == 0 ? 'gk' : 'k'", {
	expr = true,
	silent = true,
})

util.keymap({ "n", "i" }, "<A-j>", "<cmd>m .+1<cr>==", {
	desc = "Move line down",
})
util.keymap({ "n", "i" }, "<A-k>", "<cmd>m .-2<cr>==", {
	desc = "Move line up",
})
util.keymap("i", "<A-j>", "<esc><cmd>m .+1<cr>==gi", {
	desc = "Move line down",
})
util.keymap("i", "<A-k>", "<esc><cmd>m .-2<cr>==gi", {
	desc = "Move line up",
})
util.keymap("v", "<A-j>", ":m '>+1<cr>gv=gv", {
	desc = "Move line down",
})
util.keymap("v", "<A-k>", ":m '<-2<cr>gv=gv", {
	desc = "Move line up",
})

util.keymap("n", "n", "'Nn'[v:searchforward].'zv'", {
	expr = true,
	desc = "Next Search Result",
})
util.keymap("x", "n", "'Nn'[v:searchforward]", {
	expr = true,
	desc = "Next Search Result",
})
util.keymap("o", "n", "'Nn'[v:searchforward]", {
	expr = true,
	desc = "Next Search Result",
})
util.keymap("n", "N", "'nN'[v:searchforward].'zv'", {
	expr = true,
	desc = "Prev Search Result",
})
util.keymap("x", "N", "'nN'[v:searchforward]", {
	expr = true,
	desc = "Prev Search Result",
})
util.keymap("o", "N", "'nN'[v:searchforward]", {
	expr = true,
	desc = "Prev Search Result",
})
