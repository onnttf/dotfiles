local augroup = vim.api.nvim_create_augroup("user_config_autocmd", { clear = true })

-- Clear the |jumplist| at startup to avoid stale entries from previous sessions. |:clearjumps|
vim.api.nvim_create_autocmd("VimEnter", {
	group    = augroup,
	desc     = "Clear jumplist on startup",
	callback = function()
		vim.cmd("clearjumps")
	end,
})

-- Briefly highlight the yanked region. |TextYankPost| |vim.highlight.on_yank()|
vim.api.nvim_create_autocmd("TextYankPost", {
	group    = augroup,
	desc     = "Highlight yanked text",
	callback = function()
		vim.highlight.on_yank({ higroup = "IncSearch", timeout = 200 })
	end,
})

-- Auto-create missing parent directories when saving a new file. |BufWritePre| |:mkdir|
vim.api.nvim_create_autocmd("BufWritePre", {
	group    = augroup,
	desc     = "Create missing parent directories on save",
	callback = function(event)
		if event.match:match("^%w%w+:[\\/][\\/]") then
			return
		end
		local dir = vim.fn.fnamemodify(event.file, ":p:h")
		vim.fn.mkdir(dir, "p")
	end,
})

-- Map |q| to close utility buffers (|help|, quickfix, man, dap, neo-tree, etc.).
vim.api.nvim_create_autocmd("FileType", {
	group    = augroup,
	desc     = "Close utility buffers with q",
	callback = function(event)
		local ft           = event.match
		local utility_fts  = {
			help = true, lspinfo = true, qf      = true,
			man  = true, dap     = true, trouble = true,
		}
		if utility_fts[ft] or ft:find("neo%-tree") then
			vim.bo[event.buf].buflisted = false
			vim.keymap.set("n", "q", "<cmd>close<CR>", { buffer = event.buf, silent = true })
		end
	end,
})

-- Restore the cursor to its last known position when reopening a file. |'`"'| |BufReadPost|
vim.api.nvim_create_autocmd("BufReadPost", {
	group    = augroup,
	desc     = "Restore cursor position",
	callback = function(event)
		if vim.fn.line("'\"") > 1 and vim.fn.line("'\"") <= vim.api.nvim_buf_line_count(event.buf) then
			pcall(vim.cmd.normal, '"`')
		end
	end,
})

-- Re-balance split windows when the terminal is resized. |VimResized| |CTRL-W_=|
vim.api.nvim_create_autocmd("VimResized", {
	group    = augroup,
	desc     = "Balance splits on terminal resize",
	callback = function()
		vim.cmd.wincmd("=")
	end,
})
