-- Neovim configuration entry point

vim.g.mapleader = " "
vim.g.maplocalleader = " "

require("option")
require("plugin")
require("autocommand")
require("keymap")
require("filetype-config")

local wk = require("which-key")

wk.add({
	{ "<leader>f", group = "Find" },
	{ "<leader>ff", "<cmd>FzfLua files<cr>", desc = "Find files" },
	{ "<leader>fg", "<cmd>FzfLua live_grep<cr>", desc = "Live grep" },
	{ "<leader>fb", "<cmd>FzfLua buffers<cr>", desc = "Find buffers" },
	{ "<leader>fh", "<cmd>FzfLua help_tags<cr>", desc = "Help tags" },
	{ "<leader>fr", "<cmd>FzfLua oldfiles<cr>", desc = "Recent files" },
	{ "<leader>fc", "<cmd>FzfLua commands<cr>", desc = "Commands" },
	{ "<leader>fm", "<cmd>FzfLua marks<cr>", desc = "Marks" },
	{ "<leader>fq", "<cmd>FzfLua quickfix<cr>", desc = "Quickfix list" },

	{ "<leader>e", group = "Explorer" },
	{ "<leader>et", "<cmd>Neotree toggle<cr>", desc = "Toggle file tree" },
	{ "<leader>er", "<cmd>Neotree reveal<cr>", desc = "Reveal current file" },
	{ "<leader>eb", "<cmd>Neotree buffers toggle<cr>", desc = "Buffer list" },
	{ "<leader>es", "<cmd>Neotree document_symbols toggle<cr>", desc = "Document symbols" },

	{ "<leader>g", group = "Git" },
	{ "<leader>gf", "<cmd>FzfLua git_files<cr>", desc = "Git files" },
	{ "<leader>gc", "<cmd>FzfLua git_commits<cr>", desc = "Git commits" },
	{ "<leader>gb", "<cmd>FzfLua git_branches<cr>", desc = "Git branches" },
	{ "<leader>gs", "<cmd>FzfLua git_status<cr>", desc = "Git status" },

	{ "<leader>l", group = "LSP" },
	{ "<leader>lr", "<cmd>lua vim.lsp.buf.rename()<cr>", desc = "Rename" },
	{ "<leader>la", "<cmd>lua vim.lsp.buf.code_action()<cr>", desc = "Code actions" },
	{ "<leader>lf", "<cmd>lua vim.lsp.buf.format()<cr>", desc = "Format" },
	{ "<leader>li", "<cmd>LspInfo<cr>", desc = "LSP info" },
	{ "<leader>lI", "<cmd>LspInstallInfo<cr>", desc = "LSP install info" },
	{ "<leader>ld", "<cmd>lua vim.diagnostic.open_float()<cr>", desc = "Line diagnostics" },
	{ "<leader>lq", "<cmd>lua vim.diagnostic.setloclist()<cr>", desc = "Loclist diagnostics" },

	{ "<leader>d", group = "Debug" },
	{ "<leader>dc", "<cmd>lua require('dap').continue()<cr>", desc = "Continue" },
	{ "<leader>db", "<cmd>lua require('dap').toggle_breakpoint()<cr>", desc = "Toggle breakpoint" },
	{ "<leader>dB", "<cmd>lua require('dap').set_breakpoint(vim.fn.input('Breakpoint condition: '))<cr>", desc = "Conditional breakpoint" },
	{ "<leader>do", "<cmd>lua require('dap').step_over()<cr>", desc = "Step over" },
	{ "<leader>di", "<cmd>lua require('dap').step_into()<cr>", desc = "Step into" },
	{ "<leader>dO", "<cmd>lua require('dap').step_out()<cr>", desc = "Step out" },
	{ "<leader>dr", "<cmd>lua require('dap').repl.open()<cr>", desc = "REPL" },
	{ "<leader>dl", "<cmd>lua require('dap').run_last()<cr>", desc = "Run last" },
	{ "<leader>du", "<cmd>lua require('dapui').toggle()<cr>", desc = "Toggle UI" },

	{ "<leader>b", group = "Buffer" },
	{ "<leader>bn", "<cmd>bnext<cr>", desc = "Next buffer" },
	{ "<leader>bp", "<cmd>bprevious<cr>", desc = "Previous buffer" },
	{ "<leader>bd", "<cmd>bdelete<cr>", desc = "Delete buffer" },
	{ "<leader>bw", "<cmd>w<cr>", desc = "Write buffer" },

	{ "<leader>w", group = "Window" },
	{ "<leader>ws", "<cmd>split<cr>", desc = "Horizontal split" },
	{ "<leader>wv", "<cmd>vsplit<cr>", desc = "Vertical split" },
	{ "<leader>wd", "<cmd>close<cr>", desc = "Close window" },
	{ "<leader>wo", "<cmd>only<cr>", desc = "Close other windows" },

	{ "<leader>t", group = "Tabs" },
	{ "<leader>tn", "<cmd>tabnew<cr>", desc = "New tab" },
	{ "<leader>tc", "<cmd>tabclose<cr>", desc = "Close tab" },
	{ "<leader>to", "<cmd>tabonly<cr>", desc = "Close other tabs" },
	{ "<leader>tp", "<cmd>tabprevious<cr>", desc = "Previous tab" },
	{ "<leader>tj", "<cmd>tabnext<cr>", desc = "Next tab" },

	{ "<leader>q", group = "Quit/Session" },
	{ "<leader>qq", "<cmd>qa<cr>", desc = "Quit all" },
	{ "<leader>qw", "<cmd>wqa<cr>", desc = "Save and quit all" },
	{ "<leader>qo", "<cmd>only<cr>", desc = "Close other windows" },
})
