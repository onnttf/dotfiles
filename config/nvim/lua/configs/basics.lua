local opt = vim.opt

-- UI Settings
opt.number = true -- Display line numbers
opt.cursorline = true -- Highlight current line
opt.scrolloff = 8 -- Lines to keep above and below the cursor when scrolling
opt.sidescrolloff = 8 -- Columns to keep to the left and right of the cursor when scrolling
opt.colorcolumn = "200" -- Highlight column 200

-- Search Settings
opt.ignorecase = true -- Case-insensitive searching
opt.smartcase = true -- Case-sensitive if there's an uppercase character in the search

-- File Handling
opt.backup = false -- Disable backups
opt.writebackup = false -- Disable writing backups before overwriting
opt.swapfile = false -- Disable swap file creation

-- Window and Layout
opt.splitbelow = true -- Split below current window
opt.splitright = true -- Split to the right of the current window
opt.signcolumn = "yes" -- Always show the sign column

-- Clipboard
opt.clipboard = "unnamedplus" -- Use system clipboard for copy-pasting

-- Undo Settings
opt.undofile = true -- Enable persistent undo

-- Indentation and Tabs
opt.tabstop = 4 -- Number of spaces that a <Tab> counts for
opt.softtabstop = 4 -- Number of spaces inserted for each <Tab>
opt.shiftwidth = 4 -- Number of spaces to use for autoindent
opt.expandtab = true -- Use spaces instead of tabs
