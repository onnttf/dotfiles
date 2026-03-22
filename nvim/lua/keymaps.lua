vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR><cmd>let @/ = ''<CR>", { desc = "Clear search highlight" })

vim.keymap.set("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, desc = "Move down" })
vim.keymap.set("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, desc = "Move up" })

vim.keymap.set("n", "Q", "<Nop>", { desc = "Disable Ex mode" })

vim.keymap.set("n", "[b", function()
	vim.cmd.bprevious({ count = vim.v.count1 })
end, { desc = "Previous buffer" })
vim.keymap.set("n", "]b", function()
	vim.cmd.bnext({ count = vim.v.count1 })
end, { desc = "Next buffer" })
vim.keymap.set("n", "[B", "<cmd>bfirst<CR>", { desc = "First buffer" })
vim.keymap.set("n", "]B", "<cmd>blast<CR>", { desc = "Last buffer" })

vim.keymap.set("n", "[q", function()
	vim.cmd.cprevious({ count = vim.v.count1 })
end, { desc = "Previous quickfix" })
vim.keymap.set("n", "]q", function()
	vim.cmd.cnext({ count = vim.v.count1 })
end, { desc = "Next quickfix" })
vim.keymap.set("n", "[Q", "<cmd>cfirst<CR>", { desc = "First quickfix" })
vim.keymap.set("n", "]Q", "<cmd>clast<CR>", { desc = "Last quickfix" })

vim.keymap.set("n", "[l", function()
	vim.cmd.lprevious({ count = vim.v.count1 })
end, { desc = "Previous location" })
vim.keymap.set("n", "]l", function()
	vim.cmd.lnext({ count = vim.v.count1 })
end, { desc = "Next location" })
vim.keymap.set("n", "[L", "<cmd>lfirst<CR>", { desc = "First location" })
vim.keymap.set("n", "]L", "<cmd>llast<CR>", { desc = "Last location" })

vim.keymap.set("n", "[<Space>", function()
	vim.api.nvim_buf_set_lines(
		0,
		vim.fn.line(".") - 1,
		vim.fn.line(".") - 1,
		false,
		vim.fn["repeat"]({ "" }, vim.v.count1)
	)
end, { desc = "Add line above" })
vim.keymap.set("n", "]<Space>", function()
	vim.api.nvim_buf_set_lines(0, vim.fn.line("."), vim.fn.line("."), false, vim.fn["repeat"]({ "" }, vim.v.count1))
end, { desc = "Add line below" })

vim.keymap.set("v", "an", "an", { desc = "Select outer node" })
vim.keymap.set("v", "in", "in", { desc = "Select inner node" })
vim.keymap.set({ "n", "v" }, "]n", "]n", { desc = "Next treesitter node" })
vim.keymap.set({ "n", "v" }, "[n", "[n", { desc = "Previous treesitter node" })

vim.keymap.set({ "n", "v" }, "<leader>ff", function()
	require("conform").format({ lsp_format = "fallback" })
end, { desc = "Format" })

vim.keymap.set("n", "<leader>ut", function()
	vim.cmd("packadd nvim.undotree")
	require("nvim.undotree").open()
end, { desc = "Undo tree" })

vim.keymap.set("n", "<leader>gv", function()
	local file = vim.fn.expand("%:p")
	if file == "" then
		return vim.notify("No buffer to diff", vim.log.levels.WARN)
	end
	vim.fn.system({ "git", "rev-parse", "--is-inside-work-tree" })
	if vim.v.shell_error ~= 0 then
		return vim.notify("Not in a git repo", vim.log.levels.WARN)
	end
	local rel = vim.fn.system({ "git", "ls-files", "--full-name", file }):gsub("%s+$", "")
	if rel == "" then
		return vim.notify("File not tracked in git yet", vim.log.levels.WARN)
	end
	vim.cmd("packadd nvim.difftool")
	local tmp = vim.fn.tempname()
	vim.fn.system("git show HEAD:" .. vim.fn.shellescape(rel) .. " > " .. vim.fn.shellescape(tmp))
	if vim.v.shell_error ~= 0 then
		return vim.notify("Failed to get HEAD version", vim.log.levels.WARN)
	end
	vim.cmd("DiffTool " .. vim.fn.fnameescape(tmp) .. " " .. vim.fn.fnameescape(file))
end, { desc = "Git diff vs HEAD" })

vim.keymap.set("n", "<leader>sf", function()
	require("fzf-lua").files()
end, { desc = "Find files" })
vim.keymap.set("n", "<leader>sg", function()
	require("fzf-lua").live_grep()
end, { desc = "Live grep" })
vim.keymap.set("n", "<leader>sb", function()
	require("fzf-lua").buffers()
end, { desc = "Buffers" })
vim.keymap.set("n", "<leader>sh", function()
	require("fzf-lua").helptags()
end, { desc = "Help tags" })
vim.keymap.set("n", "<leader>sr", function()
	require("fzf-lua").oldfiles()
end, { desc = "Recent files" })
vim.keymap.set("n", "<leader>sw", function()
	require("fzf-lua").grep_cword()
end, { desc = "Grep word" })

vim.keymap.set("n", "<F5>", "<cmd>DapContinue<CR>", { desc = "Continue" })
vim.keymap.set("n", "<F9>", "<cmd>DapToggleBreakpoint<CR>", { desc = "Toggle breakpoint" })
vim.keymap.set("n", "<F10>", "<cmd>DapStepOver<CR>", { desc = "Step over" })
vim.keymap.set("n", "<F11>", "<cmd>DapStepInto<CR>", { desc = "Step into" })
vim.keymap.set("n", "<F12>", "<cmd>DapStepOut<CR>", { desc = "Step out" })
vim.keymap.set("n", "<leader>dt", "<cmd>DapTerminate<CR>", { desc = "Terminate" })
vim.keymap.set("n", "<leader>dr", function()
	require("dap").run_to_cursor()
end, { desc = "Run to cursor" })
vim.keymap.set("n", "<leader>db", function()
	require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))
end, { desc = "Conditional breakpoint" })
vim.keymap.set("n", "<leader>dL", function()
	require("dap").set_breakpoint(nil, nil, vim.fn.input("Log point message: "))
end, { desc = "Log point" })
