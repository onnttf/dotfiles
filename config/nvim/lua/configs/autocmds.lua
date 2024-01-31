-- Load 'utils' module here
local utils = require("utils.utils")

-- Define a function for creating auto commands groups
local augroup = function(name)
	return vim.api.nvim_create_augroup("AutoGroup_" .. name, {
		clear = true,
	})
end

-- Define a function for creating auto commands
local autocmd = vim.api.nvim_create_autocmd

-- Auto commands to check if the file needs to be reloaded when it changes
autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
	group = augroup("checktime"),
	command = "checktime",
})

-- Auto command to highlight on yank
autocmd("TextYankPost", {
	group = augroup("text_yank_post"),
	callback = vim.highlight.on_yank,
})

-- Auto command to resize splits if the window is resized
autocmd("VimResized", {
	group = augroup("vim_resized"),
	callback = function()
		vim.cmd("tabdo wincmd =")
	end,
})

-- Auto command to go to the last location when opening a buffer
autocmd("BufReadPost", {
	group = augroup("buf_read_post"),
	callback = function()
		local mark = vim.api.nvim_buf_get_mark(0, '"')
		local lcount = vim.api.nvim_buf_line_count(0)
		if mark[1] > 0 and mark[1] <= lcount then
			pcall(vim.api.nvim_win_set_cursor, 0, mark)
		end
	end,
})

-- Auto command to close some filetypes with <q>
autocmd("FileType", {
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

-- Auto command to create a directory when saving a file, in case some intermediate directory does not exist
autocmd("BufWritePre", {
	group = augroup("auto_mkdir"),
	callback = function(event)
		if event.match:match("^%w%w+://") then
			return
		end
		local file = vim.loop.fs_realpath(event.match) or event.match
		vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
	end,
})

-- Auto command to remove trailing whitespaces and insert a newline at the end of the file
autocmd("BufWritePre", {
	group = augroup("auto_add_empty_line"),
	callback = function()
		local last_line = vim.fn.line("$")
		local last_line_content = vim.fn.getline(last_line)
		local trimmed_content = vim.fn.substitute(last_line_content, "\\s\\+$", "", "")
		vim.fn.setline(last_line, trimmed_content)
		if last_line == 1 or trimmed_content ~= "" then
			vim.fn.append(last_line, "")
		end
	end,
})
