local function map(mode, lhs, rhs, desc, opts)
	opts = vim.tbl_extend("force", {
		silent = true,
		noremap = true,
		desc = desc,
	}, opts or {})

	vim.keymap.set(mode, lhs, rhs, opts)
end

local function cmd(command)
	return "<cmd>" .. command .. "<cr>"
end

-- Editing.
map("n", "<esc>", function()
	vim.cmd.nohlsearch()
	vim.fn.setreg("/", "")
end, "Edit: Clear search highlight")

map("n", "j", "v:count == 0 ? 'gj' : 'j'", "Move: Down", { expr = true })
map("n", "k", "v:count == 0 ? 'gk' : 'k'", "Move: Up", { expr = true })

map("n", "Q", "<nop>", "Edit: Disable Ex mode")

map("n", "[<space>", function()
	vim.api.nvim_buf_set_lines(
		0,
		vim.fn.line(".") - 1,
		vim.fn.line(".") - 1,
		false,
		vim.fn["repeat"]({ "" }, vim.v.count1)
	)
end, "Edit: Add line above")

map("n", "]<space>", function()
	vim.api.nvim_buf_set_lines(0, vim.fn.line("."), vim.fn.line("."), false, vim.fn["repeat"]({ "" }, vim.v.count1))
end, "Edit: Add line below")

-- Buffers.
map("n", "[b", function()
	vim.cmd.bprevious({ count = vim.v.count1 })
end, "Buffer: Previous")

map("n", "]b", function()
	vim.cmd.bnext({ count = vim.v.count1 })
end, "Buffer: Next")

map("n", "[B", cmd("bfirst"), "Buffer: First")
map("n", "]B", cmd("blast"), "Buffer: Last")
map("n", "<leader>bd", cmd("bdelete"), "Buffer: Delete")

-- Quickfix.
map("n", "[q", function()
	vim.cmd.cprevious({ count = vim.v.count1 })
end, "Quickfix: Previous")

map("n", "]q", function()
	vim.cmd.cnext({ count = vim.v.count1 })
end, "Quickfix: Next")

map("n", "[Q", cmd("cfirst"), "Quickfix: First")
map("n", "]Q", cmd("clast"), "Quickfix: Last")
map("n", "<leader>qo", cmd("copen"), "Quickfix: Open")
map("n", "<leader>qc", cmd("cclose"), "Quickfix: Close")

-- Location list.
map("n", "[l", function()
	vim.cmd.lprevious({ count = vim.v.count1 })
end, "Location: Previous")

map("n", "]l", function()
	vim.cmd.lnext({ count = vim.v.count1 })
end, "Location: Next")

map("n", "[L", cmd("lfirst"), "Location: First")
map("n", "]L", cmd("llast"), "Location: Last")

-- Code.
map({ "n", "x" }, "<leader>cf", function()
	require("conform").format({
		lsp_format = "fallback",
	})
end, "Code: Format")

-- Search.
map("n", "<leader>sf", function()
	require("fzf-lua").files()
end, "Search: Files")

map("n", "<leader>sg", function()
	require("fzf-lua").live_grep()
end, "Search: Live grep")

map("n", "<leader>sb", function()
	require("fzf-lua").buffers()
end, "Search: Buffers")

map("n", "<leader>sh", function()
	require("fzf-lua").helptags()
end, "Search: Help tags")

map("n", "<leader>sr", function()
	require("fzf-lua").oldfiles()
end, "Search: Recent files")

map("n", "<leader>sw", function()
	require("fzf-lua").grep_cword()
end, "Search: Word under cursor")

map("n", "<leader>sk", function()
	require("fzf-lua").keymaps()
end, "Search: Keymaps")

map("n", "<leader>sc", function()
	require("fzf-lua").commands()
end, "Search: Commands")

map("n", "<leader>sd", function()
	require("fzf-lua").diagnostics_document()
end, "Search: Document diagnostics")

map("n", "<leader>sD", function()
	require("fzf-lua").diagnostics_workspace()
end, "Search: Workspace diagnostics")

-- Git.
local function diff_current_file_with_head()
	local file = vim.fn.expand("%:p")

	if file == "" then
		vim.notify("No buffer to diff", vim.log.levels.WARN)
		return
	end

	vim.fn.system({ "git", "rev-parse", "--is-inside-work-tree" })

	if vim.v.shell_error ~= 0 then
		vim.notify("Not in a git repo", vim.log.levels.WARN)
		return
	end

	local rel = vim.fn.system({ "git", "ls-files", "--full-name", file }):gsub("%s+$", "")

	if rel == "" then
		vim.notify("File not tracked in git yet", vim.log.levels.WARN)
		return
	end

	vim.cmd("packadd nvim.difftool")

	local tmp = vim.fn.tempname()

	vim.fn.system("git show HEAD:" .. vim.fn.shellescape(rel) .. " > " .. vim.fn.shellescape(tmp))

	if vim.v.shell_error ~= 0 then
		vim.notify("Failed to get HEAD version", vim.log.levels.WARN)
		return
	end

	vim.cmd("DiffTool " .. vim.fn.fnameescape(tmp) .. " " .. vim.fn.fnameescape(file))
end

map("n", "<leader>gd", diff_current_file_with_head, "Git: Diff current file with HEAD")

-- Debug.
map("n", "<leader>dc", cmd("DapContinue"), "Debug: Continue")
map("n", "<leader>db", cmd("DapToggleBreakpoint"), "Debug: Toggle breakpoint")
map("n", "<leader>do", cmd("DapStepOver"), "Debug: Step over")
map("n", "<leader>di", cmd("DapStepInto"), "Debug: Step into")
map("n", "<leader>dO", cmd("DapStepOut"), "Debug: Step out")
map("n", "<leader>dt", cmd("DapTerminate"), "Debug: Terminate")

map("n", "<leader>dr", function()
	require("dap").run_to_cursor()
end, "Debug: Run to cursor")

map("n", "<leader>dB", function()
	require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))
end, "Debug: Conditional breakpoint")

map("n", "<leader>dL", function()
	require("dap").set_breakpoint(nil, nil, vim.fn.input("Log point message: "))
end, "Debug: Log point")

-- UI.
map("n", "<leader>uu", function()
	vim.cmd("packadd nvim.undotree")
	require("nvim.undotree").open()
end, "UI: Undo tree")
