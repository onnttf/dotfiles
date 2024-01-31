-- Use a local reference to vim.opt for brevity
local opt = vim.opt

-- General options

-- Show line numbers
opt.number = true

-- Highlight current line
opt.cursorline = true

-- Set padding for jkhl
opt.scrolloff = 8
opt.sidescrolloff = 8

-- Set line of reference on right
opt.colorcolumn = "200"

-- Search options

-- Ignore case when searching
opt.ignorecase = true

-- Don't ignore case if pattern has an upper case
opt.smartcase = true

-- File handling options

-- Disable backup files
opt.backup = false
opt.writebackup = false

-- Disable swap files
opt.swapfile = false

-- Window splitting options

-- Splits will be below
opt.splitbelow = true

-- Splits will be to the right
opt.splitright = true

-- Clipboard options

-- Use clipboard for all operations
opt.clipboard = "unnamed,unnamedplus"

-- GUI and appearance options

-- Enable GUI colors
opt.termguicolors = true

-- Always show the signcolumn, otherwise it would shift the text each time
opt.signcolumn = "yes"

-- Tab settings

-- Set tabstop, softtabstop, shiftwidth, and use expandtab
opt.tabstop = 4
opt.softtabstop = 4
opt.shiftwidth = 4
opt.expandtab = true
