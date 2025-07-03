-- [[ Autocommand ]]

-- Group for user-defined autocommands.
local augroup = vim.api.nvim_create_augroup("user_config_autocommand", { clear = true })

-- Highlight yanked text on copy.
vim.api.nvim_create_autocmd("TextYankPost", {
	group = augroup,
	desc = "Highlight: Yanked text",
	callback = function()
		vim.highlight.on_yank()
	end,
})

-- Create parent directories on file save.
vim.api.nvim_create_autocmd("BufWritePre", {
	group = augroup,
	desc = "File: Create parent directories on save",
	callback = function(event)
		-- Skip remote or special paths.
		if event.match:match("^%w%w+:[\\/][\\/]") then
			return
		end
		local dir = vim.fn.fnamemodify(event.file, ":p:h")
		vim.fn.mkdir(dir, "p")
	end,
})

-- Enable 'q' to close utility buffers.
vim.api.nvim_create_autocmd("FileType", {
	group = augroup,
	desc = "Buffer: Close utility buffers with 'q'",
	pattern = { "help", "lspinfo", "neo-tree", "qf" },
	callback = function(event)
		-- Ensure these buffers are not listed.
		vim.bo[event.buf].buflisted = false
		vim.keymap.set("n", "q", "<cmd>close<CR>", { buffer = event.buf, silent = true })
	end,
})

-- Restore cursor to last position.
vim.api.nvim_create_autocmd("BufReadPost", {
	group = augroup,
	desc = "Cursor: Restore last position on buffer read",
	callback = function()
		local last_pos_mark = vim.api.nvim_buf_get_mark(0, '"')
		local lcount = vim.api.nvim_buf_line_count(0)
		-- Only jump if the mark is valid.
		if last_pos_mark[1] > 0 and last_pos_mark[1] <= lcount then
			pcall(vim.api.nvim_win_set_cursor, 0, last_pos_mark)
		end
	end,
})

-- Auto-balance window splits on resize.
vim.api.nvim_create_autocmd("VimResized", {
	group = augroup,
	desc = "Window: Auto-balance splits on resize",
	callback = function()
		vim.cmd("wincmd =")
	end,
})
