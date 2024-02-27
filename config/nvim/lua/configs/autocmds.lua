-- Importing utility functions
local utils = require("utils.utils")

-- Function to create autocmd groups
local augroup = function(name)
	return vim.api.nvim_create_augroup("AutoGroup_" .. name, {
		clear = true,
	})
end

local autocmd = vim.api.nvim_create_autocmd

-- Auto commands for various events

-- Checktime on FocusGained, TermClose, and TermLeave
autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
	group = augroup("checktime"),
	command = "checktime",
	desc = "Automatically run :checktime on FocusGained, TermClose, and TermLeave",
})

-- Highlight when yanking (copying) text on TextYankPost
autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = augroup("highlight-yank"),
	callback = vim.highlight.on_yank,
})

-- Resize windows equally on VimResized
autocmd("VimResized", {
	desc = "Resize windows equally on VimResized",
	group = augroup("vim_resized"),
	callback = function()
		vim.cmd("tabdo wincmd =")
	end,
})

-- Restore cursor position on BufReadPost
autocmd("BufReadPost", {
	desc = "Restore cursor position on BufReadPost",
	group = augroup("buf_read_post"),
	callback = function()
		local mark = vim.api.nvim_buf_get_mark(0, '"')
		local lcount = vim.api.nvim_buf_line_count(0)
		if mark[1] > 0 and mark[1] <= lcount then
			pcall(vim.api.nvim_win_set_cursor, 0, mark)
		end
	end,
})

-- Customize settings and keymap for specific file types on FileType
autocmd("FileType", {
	desc = "Customize settings and keymap for specific file types on FileType",
	group = augroup("close"),
	pattern = {
		"PlenaryTestPopup",
		"help",
		"lspinfo",
		"man",
		"notify",
		"qf",
		"spectre_panel",
		"startuptime",
		"tsplayground",
		"checkhealth",
	},
	callback = function(event)
		vim.bo[event.buf].buflisted = false
		utils.keymap("n", "q", "<cmd>close<cr>", {
			desc = "Close file.",
		})
	end,
})

-- Automatically create missing directories on BufWritePre
autocmd("BufWritePre", {
	desc = "Automatically create missing directories on BufWritePre",
	group = augroup("auto_mkdir"),
	callback = function(event)
		if event.match:match("^%w%w+://") then
			return
		end
		local file = vim.loop.fs_realpath(event.match) or event.match
		vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
	end,
})
