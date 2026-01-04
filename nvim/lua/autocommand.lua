-- Autocommands for Neovim configuration

local augroup = vim.api.nvim_create_augroup("user_config_autocommand", {
	clear = true,
})

-- Highlight yanked text for visual feedback
vim.api.nvim_create_autocmd("TextYankPost", {
	group = augroup,
	desc = "Highlight yank",
	callback = function()
		vim.highlight.on_yank()
	end,
})

-- Create parent directories if they do not exist
vim.api.nvim_create_autocmd("BufWritePre", {
	group = augroup,
	desc = "Create dirs on save",
	callback = function(event)
		-- Skip remote files
		if event.match:match("^%w%w+:[\\/][\\/]") then
			return
		end
		
		local dir = vim.fn.fnamemodify(event.file, ":p:h")
		vim.fn.mkdir(dir, "p")
	end,
})

-- Set q to close utility buffers
vim.api.nvim_create_autocmd("FileType", {
	group = augroup,
	desc = "Close utility with q",
	callback = function(event)
		local buf = event.buf
		local ft = vim.bo[buf].filetype or ""
		
		local utility_patterns = {
			"help",
			"lspinfo", 
			"qf",
			"man",
			"startuptime",
			"dap",
			"trouble",
			"neo%-tree",
		}
		
		for _, pattern in ipairs(utility_patterns) do
			if ft:lower():match(pattern:lower()) then
				vim.bo[buf].buflisted = false
				vim.keymap.set("n", "q", "<cmd>close<CR>", {
					buffer = buf,
					silent = true,
				})
				return
			end
		end
	end,
})

-- Restore last cursor position when reopening a file
vim.api.nvim_create_autocmd("BufReadPost", {
	group = augroup,
	desc = "Restore cursor position",
	callback = function()
		local mark = vim.api.nvim_buf_get_mark(0, '"')
		local line_count = vim.api.nvim_buf_line_count(0)
		
		if mark[1] > 0 and mark[1] <= line_count then
			pcall(vim.api.nvim_win_set_cursor, 0, mark)
		end
	end,
})

-- Automatically balance split windows when resizing
vim.api.nvim_create_autocmd("VimResized", {
	group = augroup,
	desc = "Balance splits on resize",
	callback = function()
		vim.cmd("wincmd =")
	end,
})
