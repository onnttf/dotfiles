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

-- Treesitter incremental selection, with LSP selection-range fallback.
map({ "x", "o" }, "an", function()
	if vim.treesitter.get_parser(nil, nil, { error = false }) then
		vim.treesitter.select("parent", vim.v.count1)
	else
		vim.lsp.buf.selection_range(vim.v.count1)
	end
end, "Select: Parent node")

map({ "x", "o" }, "in", function()
	if vim.treesitter.get_parser(nil, nil, { error = false }) then
		vim.treesitter.select("child", vim.v.count1)
	else
		vim.lsp.buf.selection_range(-vim.v.count1)
	end
end, "Select: Child node")

map("x", "]n", function()
	vim.treesitter.select("next", vim.v.count1)
end, "Select: Next node")

map("x", "[n", function()
	vim.treesitter.select("prev", vim.v.count1)
end, "Select: Previous node")

map("x", "]N", function()
	vim.treesitter.select("extend_next", vim.v.count1)
end, "Select: Next sibling node")

map("x", "[N", function()
	vim.treesitter.select("extend_prev", vim.v.count1)
end, "Select: Previous sibling node")

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

map("n", "<leader>u", function()
	vim.cmd.packadd("nvim.undotree")
	vim.cmd.Undotree()
end, "Edit: Undo tree")

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

-- LSP.
map({ "n", "x" }, "<leader>lf", function()
	require("conform").format({
		lsp_format = "fallback",
	})
end, "LSP: Format")

-- Copy.
local function copy(value, label)
	vim.fn.setreg("+", value)
	vim.notify(("Copied %s: %s"):format(label, value))
end

map("n", "<leader>cp", function()
	copy(vim.api.nvim_buf_get_name(0), "path")
end, "Copy: Absolute path")

map("n", "<leader>cr", function()
	copy(vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":."), "relative path")
end, "Copy: Relative path")

map("n", "<leader>cd", function()
	local diagnostics = vim.diagnostic.get(0, { lnum = vim.api.nvim_win_get_cursor(0)[1] - 1 })
	if #diagnostics == 0 then
		vim.notify("No diagnostics on current line", vim.log.levels.INFO)
		return
	end

	copy(
		table.concat(
			vim.tbl_map(function(diagnostic)
				return diagnostic.message
			end, diagnostics),
			"\n"
		),
		"diagnostics"
	)
end, "Copy: Line diagnostics")

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
