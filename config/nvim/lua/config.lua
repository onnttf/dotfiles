-- Set map leader and local map leader to space
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Check if Nerd Font is installed
vim.g.have_nerd_font = false

-- Enable line numbers
vim.opt.number = true

-- Enable mouse support in all modes
vim.opt.mouse = "a"

-- Show mode in command line
vim.opt.showmode = true

-- Use system clipboard for copy/paste
vim.opt.clipboard = "unnamedplus"

-- Enable break indent
vim.opt.breakindent = true

-- Enable persistent undo
vim.opt.undofile = true

-- Ignore case in search
vim.opt.ignorecase = true

-- Use smart case for search, ignore case if pattern is all lowercase
vim.opt.smartcase = true

-- Highlight search results
vim.opt.hlsearch = true

-- Display sign column
vim.opt.signcolumn = "yes"

-- Set the time in milliseconds for CursorHold to trigger
vim.opt.updatetime = 250

-- Set the time in milliseconds for which key mappings can be digraphs
vim.opt.timeoutlen = 300

-- Open new split to the right
vim.opt.splitright = true

-- Open new split below
vim.opt.splitbelow = true

-- Set the number of spaces that a <Tab> in the file counts for
vim.opt.tabstop = 4

-- Set the number of spaces that are inserted for <Tab> and <BS> in Insert mode
vim.opt.softtabstop = 4

-- Set the number of spaces that a pre-existing tab is converted to during editing
vim.opt.shiftwidth = 4

-- Use spaces instead of tabs
vim.opt.expandtab = true

-- Highlight current line
vim.opt.cursorline = true

-- Number of lines to keep above and below the cursor in normal mode
vim.opt.scrolloff = 10
