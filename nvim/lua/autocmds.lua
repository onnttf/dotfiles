-- |autocmds.lua| — User-defined autocommands.

local augroup = vim.api.nvim_create_augroup("user_config", { clear = true })

-- Clear |jumplist| at startup to avoid stale jumps. |VimEnter| |:clearjumps|
vim.api.nvim_create_autocmd("VimEnter", {
	group    = augroup,
	desc     = "Clear jumplist on startup",
	callback = function() vim.cmd("clearjumps") end,
})

-- Briefly highlight yanked text using |IncSearch| highlight group. |TextYankPost|
vim.api.nvim_create_autocmd("TextYankPost", {
	group    = augroup,
	desc     = "Highlight on yank",
	callback = function() vim.hl.on_yank({ higroup = "IncSearch", timeout = 200 }) end,
})

-- Create missing parent directories when saving a file. |BufWritePre|
vim.api.nvim_create_autocmd("BufWritePre", {
	group    = augroup,
	desc     = "Create missing parent dirs on save",
	callback = function(event)
		-- Skip remote URLs (e.g., scp://, rsync://).
		if event.match:match("^%w%w+:[\\/][\\/]") then return end
		vim.fn.mkdir(vim.fn.fnamemodify(event.file, ":p:h"), "p")
	end,
})

-- Close utility buffers with |q|. |FileType|
vim.api.nvim_create_autocmd("FileType", {
	group    = augroup,
	desc     = "Close utility buffers with q",
	callback = function(event)
		local ft = event.match
		local utility_fts = {
			help = true, lspinfo = true, qf = true,
			man = true, dap = true, trouble = true,
		}
		if utility_fts[ft] or ft:find("neo%-tree") then
			vim.bo[event.buf].buflisted = false
			vim.keymap.set("n", "q", "<cmd>close<CR>", { buffer = event.buf, silent = true })
		end
	end,
})

-- Enable treesitter syntax highlighting per filetype. |FileType| |vim.treesitter|
vim.api.nvim_create_autocmd("FileType", {
	group    = vim.api.nvim_create_augroup("ts_highlight", { clear = true }),
	desc     = "Enable treesitter syntax highlighting",
	callback = function(ev)
		local lang = vim.treesitter.language.get_lang(ev.match)
		if lang then pcall(vim.treesitter.start, ev.buf, lang) end
	end,
})

-- Restore cursor position when reopening a file. |BufReadPost| |'"|
vim.api.nvim_create_autocmd("BufReadPost", {
	group    = augroup,
	desc     = "Restore cursor position on file reopen",
	callback = function(event)
		if vim.fn.line("'\"") > 1 and vim.fn.line("'\"") <= vim.api.nvim_buf_line_count(event.buf) then
			pcall(vim.cmd.normal, '"`')
		end
	end,
})

-- Rebalance window splits when the terminal is resized. |VimResized| |CTRL-W_=|
vim.api.nvim_create_autocmd("VimResized", {
	group    = augroup,
	desc     = "Balance splits on terminal resize",
	callback = function() vim.cmd.wincmd("=") end,
})
