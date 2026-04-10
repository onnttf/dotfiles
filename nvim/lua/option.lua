local opt = vim.opt

opt.termguicolors  = true        -- Enable 24-bit RGB color in the |TUI|. |'termguicolors'|
opt.number         = true        -- Print the line number in front of each line. |'number'|
opt.relativenumber = false       -- Show line numbers relative to the cursor. |'relativenumber'|
opt.cursorline     = true        -- Highlight the screen line of the cursor. |'cursorline'|
opt.signcolumn     = "yes"       -- Always show the sign column to avoid layout shift. |'signcolumn'|
opt.showmode       = false       -- Mode is shown by the statusline; suppress the default. |'showmode'|
opt.wrap           = false       -- Long lines do not wrap. |'wrap'|
opt.list           = true        -- Show invisible characters defined in 'listchars'. |'list'|
opt.listchars:append({ tab = "│ ", trail = "·", nbsp = "␣" })
opt.conceallevel   = 1           -- Conceal markup in supporting filetypes (e.g. Markdown). |'conceallevel'|
opt.winborder      = "rounded"   -- Default border style for floating windows. |'winborder'| nvim 0.11+
opt.pumborder      = "rounded"   -- Border around the completion popup menu. |'pumborder'| nvim 0.12+
opt.tabstop        = 4           -- Number of spaces a <Tab> counts for. |'tabstop'|
opt.shiftwidth     = 4           -- Number of spaces per (auto)indent step. |'shiftwidth'|
opt.expandtab      = true        -- Use spaces instead of tabs. |'expandtab'|
opt.breakindent    = true        -- Wrapped lines continue at the same visual indent. |'breakindent'|
opt.ignorecase     = true        -- Ignore case in search patterns. |'ignorecase'|
opt.smartcase      = true        -- Override 'ignorecase' when pattern contains uppercase. |'smartcase'|
opt.incsearch      = true        -- Show match while the search pattern is being typed. |'incsearch'|
opt.hlsearch       = true        -- Keep all matches highlighted after searching. |'hlsearch'|
opt.inccommand     = "split"     -- Show a live preview of :substitute in a split window. |'inccommand'|
opt.scrolloff      = 8           -- Minimum lines to keep above and below the cursor. |'scrolloff'|
opt.sidescrolloff  = 8           -- Minimum columns to keep left and right of the cursor. |'sidescrolloff'|
opt.smoothscroll   = true        -- Scroll by screen lines rather than file lines. |'smoothscroll'|
opt.jumpoptions    = "view"      -- Restore the window view when traversing the |jumplist|. |'jumpoptions'|
opt.splitright     = true        -- Open vertical splits to the right. |'splitright'|
opt.splitbelow     = true        -- Open horizontal splits below. |'splitbelow'|
opt.updatetime     = 250         -- Delay (ms) before writing the swap file and firing |CursorHold|. |'updatetime'|
opt.timeoutlen     = 500         -- Time (ms) to wait for a key sequence to complete. |'timeoutlen'|
opt.undofile       = true        -- Persist undo history to disk; survives restarts. |'undofile'|
opt.foldlevel      = 99          -- Start with all folds open. foldexpr is set per-buffer by treesitter/LSP. |'foldlevel'|
opt.clipboard      = "unnamedplus" -- Synchronise the unnamed register with the system clipboard. |'clipboard'|
opt.shortmess:append({ W = true, I = true, c = true }) -- Suppress various informational messages. |'shortmess'|

-- Virtual text with a bullet prefix, sorted by severity, silent in insert mode.
-- |vim.diagnostic.config()| |diagnostic-config|
vim.diagnostic.config({
	virtual_text     = { spacing = 2, prefix = "●" },
	signs            = true,
	underline        = true,
	severity_sort    = true,
	update_in_insert = false,
})
