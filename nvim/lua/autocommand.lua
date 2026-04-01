local augroup = vim.api.nvim_create_augroup("user_config_autocommand", { clear = true })

-- TextYankPost: briefly highlight the yanked region (:h TextYankPost, vim.highlight.on_yank)
vim.api.nvim_create_autocmd("TextYankPost", {
	group = augroup,
	desc = "Highlight yank",
	callback = function()
		vim.highlight.on_yank()
	end,
})

-- BufWritePre: create missing parent directories before writing (:h BufWritePre)
vim.api.nvim_create_autocmd("BufWritePre", {
	group = augroup,
	desc = "Create dirs on save",
	callback = function(event)
		if event.match:match("^%w%w+:[\\/][\\/]") then
			return
		end
		local dir = vim.fn.fnamemodify(event.file, ":p:h")
		vim.fn.mkdir(dir, "p")
	end,
})

-- FileType: map q to :close for transient/utility buffers (:h special-buffers)
vim.api.nvim_create_autocmd("FileType", {
	group = augroup,
	desc = "Close utility with q",
	callback = function(event)
		local buf = event.buf
		local ft = vim.bo[buf].filetype or ""
		local utility_patterns = {
			"help", "lspinfo", "qf", "man", "startuptime",
			"dap", "trouble", "neo%-tree",
		}
		for _, pattern in ipairs(utility_patterns) do
			if ft:lower():match(pattern:lower()) then
				vim.bo[buf].buflisted = false
				vim.keymap.set("n", "q", "<cmd>close<CR>", {
					buf = buf,
					silent = true,
				})
				return
			end
		end
	end,
})

-- BufReadPost: restore last cursor position using the '" mark (:h last-position-jump)
vim.api.nvim_create_autocmd("BufReadPost", {
	group = augroup,
	desc = "Restore cursor position",
	callback = function(event)
		local mark = vim.api.nvim_buf_get_mark(event.buf, '"')
		local line_count = vim.api.nvim_buf_line_count(event.buf)
		if mark[1] > 0 and mark[1] <= line_count then
			pcall(vim.api.nvim_win_set_cursor, 0, mark)
		end
	end,
})

-- VimResized: equalize all window sizes after the terminal is resized (:h VimResized)
vim.api.nvim_create_autocmd("VimResized", {
	group = augroup,
	desc = "Balance splits on resize",
	callback = function()
		vim.cmd.wincmd("=")
	end,
})
