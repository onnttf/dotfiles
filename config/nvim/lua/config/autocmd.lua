local util = require("util")

local nvim_create_autocmd = vim.api.nvim_create_autocmd

nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = util.augroup("highlight-yank"),
	callback = function()
		vim.highlight.on_yank()
	end,
})

nvim_create_autocmd("VimResized", {
	desc = "Resize windows equally on VimResized",
	group = util.augroup("vim_resized"),
	callback = function()
		vim.cmd("tabdo wincmd =")
	end,
})

nvim_create_autocmd({ "BufWritePre" }, {
	group = util.augroup("auto_create_dir"),
	callback = function(event)
		if event.match:match("^%w%w+:[\\/][\\/]") then
			return
		end
		local file = vim.uv.fs_realpath(event.match) or event.match
		vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
	end,
})

nvim_create_autocmd("FileType", {
	group = util.augroup("close_with_q"),
	pattern = {
		"PlenaryTestPopup",
		"help",
		"lspinfo",
		"notify",
		"qf",
		"query",
		"spectre_panel",
		"startuptime",
		"tsplayground",
		"neotest-output",
		"checkhealth",
		"neotest-summary",
		"neotest-output-panel",
	},
	callback = function(event)
		vim.bo[event.buf].buflisted = false
		util.keymap("n", "q", "<cmd>close<cr>", {
			buffer = event.buf,
			silent = true,
		})
	end,
})

nvim_create_autocmd("BufReadPost", {
	desc = "Restore cursor position on BufReadPost",
	group = util.augroup("buf_read_post"),
	callback = function()
		local mark = vim.api.nvim_buf_get_mark(0, '"')
		local lcount = vim.api.nvim_buf_line_count(0)
		if mark[1] > 0 and mark[1] <= lcount then
			pcall(vim.api.nvim_win_set_cursor, 0, mark)
		end
	end,
})
