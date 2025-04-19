local augroup = vim.api.nvim_create_augroup("user_config_autocommand", { clear = true })

local autocmd = function(event, opts)
	opts.group = augroup
	vim.api.nvim_create_autocmd(event, opts)
end

autocmd("TextYankPost", {
	desc = "Highlight yanked text",
	callback = function()
		vim.highlight.on_yank({ higroup = "IncSearch", timeout = 150 })
	end,
})

autocmd("BufWritePre", {
	desc = "Auto-create directories when saving a file",
	callback = function(event)
		if event.match:find("^[a-zA-Z]+://") then
			return
		end

		local dir = vim.fs.dirname(vim.uv.fs_realpath(event.match) or event.match)
		if dir and not vim.loop.fs_stat(dir) then
			vim.fn.mkdir(dir, "p")
		end
	end,
})

autocmd("FileType", {
	desc = "Use 'q' to close specific buffers",
	pattern = { "help", "lspinfo", "neo-tree", "qf" },
	callback = function(event)
		local buf = event.buf
		vim.bo[buf].buflisted = false
		vim.keymap.set("n", "q", "<cmd>close<CR>", { buffer = buf, silent = true, noremap = true })
	end,
})

autocmd("BufReadPost", {
	desc = "Go to last location when reopening a file",
	callback = function()
		local mark = vim.api.nvim_buf_get_mark(0, '"')
		local lines = vim.api.nvim_buf_line_count(0)
		if mark[1] > 0 and mark[1] <= lines then
			pcall(vim.api.nvim_win_set_cursor, 0, mark)
		end
	end,
})

autocmd("VimResized", {
	desc = "Auto-resize splits on window resize",
	callback = function()
		vim.cmd("tabdo wincmd =")
	end,
})

