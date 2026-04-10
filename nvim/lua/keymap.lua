local keymap = require("util").keymap

-- Clear |'hlsearch'| and the search pattern register on <Esc>.
keymap("n", "<Esc>", "<cmd>nohlsearch<CR><cmd>let @/ = ''<CR>", { desc = "Clear Search Highlight" })

-- Smart |j|/|k|: navigate by screen lines when no [count], real lines with [count].
-- See |gj| |gk|.
keymap("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, desc = "Move Down" })
keymap("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, desc = "Move Up" })

-- Disable |Q| (Ex mode entry). |Ex-mode|
keymap("n", "Q", "<Nop>", { desc = "Disable Ex Mode" })

-- Buffer list navigation. Default mappings since nvim 0.11.              *[b* *]b*
-- Accepts [count]. See |:bprevious| |:bnext| |:bfirst| |:blast|.
keymap("n", "[b", function() vim.cmd.bprevious({ count = vim.v.count1 }) end, { desc = "Previous Buffer" })
keymap("n", "]b", function() vim.cmd.bnext({ count = vim.v.count1 }) end,     { desc = "Next Buffer" })
keymap("n", "[B", "<cmd>bfirst<CR>",                                           { desc = "First Buffer" })
keymap("n", "]B", "<cmd>blast<CR>",                                            { desc = "Last Buffer" })

-- |quickfix| list navigation. Default mappings since nvim 0.11.          *[q* *]q*
-- Accepts [count]. See |:cprevious| |:cnext| |:cfirst| |:clast|.
keymap("n", "[q", function() vim.cmd.cprevious({ count = vim.v.count1 }) end, { desc = "Previous Quickfix Item" })
keymap("n", "]q", function() vim.cmd.cnext({ count = vim.v.count1 }) end,     { desc = "Next Quickfix Item" })
keymap("n", "[Q", "<cmd>cfirst<CR>",                                           { desc = "First Quickfix Item" })
keymap("n", "]Q", "<cmd>clast<CR>",                                            { desc = "Last Quickfix Item" })

-- |location-list| navigation. Default mappings since nvim 0.11.          *[l* *]l*
-- Accepts [count]. See |:lprevious| |:lnext| |:lfirst| |:llast|.
keymap("n", "[l", function() vim.cmd.lprevious({ count = vim.v.count1 }) end, { desc = "Previous Location Item" })
keymap("n", "]l", function() vim.cmd.lnext({ count = vim.v.count1 }) end,     { desc = "Next Location Item" })
keymap("n", "[L", "<cmd>lfirst<CR>",                                           { desc = "First Location Item" })
keymap("n", "]L", "<cmd>llast<CR>",                                            { desc = "Last Location Item" })

-- Add [count] empty lines above/below cursor without moving it.
-- Default mappings since nvim 0.11. See |[<Space>-default| |]<Space>-default|.
keymap("n", "[<Space>", function()
	vim.api.nvim_buf_set_lines(0, vim.fn.line(".") - 1, vim.fn.line(".") - 1, false, vim.fn["repeat"]({ "" }, vim.v.count1))
end, { desc = "Add Empty Line Above" })
keymap("n", "]<Space>", function()
	vim.api.nvim_buf_set_lines(0, vim.fn.line("."), vim.fn.line("."), false, vim.fn["repeat"]({ "" }, vim.v.count1))
end, { desc = "Add Empty Line Below" })

-- Treesitter / LSP incremental selection. nvim 0.12+.           *v_an* *v_in*
-- |v_an|  Expand selection outward to the parent treesitter node.
-- |v_in|  Shrink selection inward to a child treesitter node.
-- Powered by |treesitter| and |lsp-selectionRange| (textDocument/selectionRange).
keymap("v", "an", "an", { desc = "Select Outer Node" })
keymap("v", "in", "in", { desc = "Select Inner Node" })

-- |v_]n| |v_[n|  Move to next/prev treesitter node. nvim 0.12+.
keymap({ "n", "v" }, "]n", "]n", { desc = "Next Treesitter Node" })
keymap({ "n", "v" }, "[n", "[n", { desc = "Previous Treesitter Node" })

-- Format buffer or range via |conform.nvim|. Falls back to |lsp-format| when
-- no formatter is configured for the filetype.
keymap({ "n", "v" }, "<leader>f", function()
	require("conform").format({ lsp_format = "fallback" })
end, { desc = "Format" })

-- Fuzzy search via fzf-lua. See https://github.com/ibhagwan/fzf-lua
keymap("n", "<leader>sf", function() require("fzf-lua").files() end,      { desc = "Find Files" })
keymap("n", "<leader>sg", function() require("fzf-lua").live_grep() end,  { desc = "Live Grep" })
keymap("n", "<leader>sb", function() require("fzf-lua").buffers() end,    { desc = "List Buffers" })
keymap("n", "<leader>sh", function() require("fzf-lua").helptags() end,   { desc = "Search Help Tags" })
keymap("n", "<leader>sr", function() require("fzf-lua").oldfiles() end,   { desc = "Recent Files" })
keymap("n", "<leader>sw", function() require("fzf-lua").grep_cword() end, { desc = "Grep Word Under Cursor" })

-- Debug adapter protocol via nvim-dap. |dap.txt|
-- Step controls occupy the function row; leader prefix for less-frequent actions.
keymap("n", "<F5>",  "<cmd>DapContinue<CR>",         { desc = "Continue" })
keymap("n", "<F9>",  "<cmd>DapToggleBreakpoint<CR>",  { desc = "Toggle Breakpoint" })
keymap("n", "<F10>", "<cmd>DapStepOver<CR>",          { desc = "Step Over" })
keymap("n", "<F11>", "<cmd>DapStepInto<CR>",          { desc = "Step Into" })
keymap("n", "<F12>", "<cmd>DapStepOut<CR>",           { desc = "Step Out" })

keymap("n", "<leader>dt", "<cmd>DapTerminate<CR>", { desc = "Terminate" })
keymap("n", "<leader>dr", function()
	require("dap").run_to_cursor()
end, { desc = "Run to Cursor" })
keymap("n", "<leader>db", function()
	require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))
end, { desc = "Conditional Breakpoint" })
keymap("n", "<leader>dL", function()
	require("dap").set_breakpoint(nil, nil, vim.fn.input("Log point message: "))
end, { desc = "Log Point" })
