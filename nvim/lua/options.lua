-- |options.lua| — Editor options configuration.

local opt = vim.opt

-- Appearance --

opt.termguicolors  = true     -- Enable 24-bit RGB color in the TUI. |'termguicolors'|
opt.number         = true     -- Print line number on the left. |'number'|
opt.relativenumber = true     -- Relative line numbers for easier motion. |'relativenumber'|
opt.cursorline     = true     -- Highlight the screen line of the cursor. |'cursorline'|
opt.signcolumn     = "yes"    -- Always show sign column; prevents layout shifts. |'signcolumn'|
opt.showmode       = false    -- Suppress --INSERT--; statusline handles mode display. |'showmode'|
opt.conceallevel   = 1        -- Conceal markup in supporting filetypes. |'conceallevel'|

-- Indentation --

opt.tabstop        = 4        -- Number of visual spaces a <Tab> represents. |'tabstop'|
opt.shiftwidth     = 4        -- Number of spaces per indent step. |'shiftwidth'|
opt.expandtab      = true     -- Expand <Tab> to spaces. |'expandtab'|
opt.breakindent    = true     -- Maintain visual indent for wrapped lines. |'breakindent'|
opt.list           = true     -- Show invisible characters. |'list'|
opt.listchars      = { tab = "│ ", trail = "·", nbsp = "␣" }

-- Search --

opt.ignorecase     = true     -- Case-insensitive search by default. |'ignorecase'|
opt.smartcase      = true     -- Case-sensitive when pattern has uppercase. |'smartcase'|
opt.incsearch      = true     -- Show match incrementally while typing. |'incsearch'|
opt.hlsearch       = true     -- Keep all matches highlighted. |'hlsearch'|
opt.maxsearchcount = 999      -- Max matches for |searchcount()|. |'maxsearchcount'|

-- Command-line --

opt.inccommand     = "split"  -- Live preview |:substitute| results. |'inccommand'|
opt.wildmode       = "longest:full,full"  -- Command-line completion mode. |'wildmode'|

-- Window splits --

opt.splitright     = true     -- Vertical splits open to the right. |'splitright'|
opt.splitbelow     = true     -- Horizontal splits open below. |'splitbelow'|

-- Scrolling --

opt.scrolloff      = 8        -- Minimum lines above/below cursor. |'scrolloff'|
opt.sidescrolloff  = 8        -- Minimum columns left/right of cursor. |'sidescrolloff'|
opt.smoothscroll   = true     -- Scroll by screen lines for smooth motion. |'smoothscroll'|
opt.jumpoptions    = "view"   -- Restore view state on |jumplist| traversal. |'jumpoptions'|

-- Timing --

opt.updatetime     = 250      -- Milliseconds before |CursorHold| fires. |'updatetime'|
opt.timeoutlen     = 500      -- Milliseconds to wait for a mapped key sequence. |'timeoutlen'|

-- Session --

opt.undofile       = true     -- Persist undo history across sessions. |'undofile'|
opt.clipboard      = "unnamedplus"  -- Sync with system clipboard. |'clipboard'|

-- Display --

opt.wrap           = false    -- Do not wrap long lines. |'wrap'|
opt.foldlevel      = 99       -- Start with all folds open. |'foldlevel'|
opt.shelltemp      = false    -- Pass shell commands via file descriptor. |'shelltemp'|

-- Completion popup --

opt.completeopt:append({ "nearest" })   -- Sort completion by proximity. |'completeopt'|
opt.pummaxwidth    = 80       -- Max width of completion popup menu. |'pummaxwidth'|
opt.pumborder      = "rounded" -- Border style around completion menu. |'pumborder'|

-- Diff --

opt.diffopt:append({ "indent-heuristic", "inline:char" })  -- Improved diff algorithm. |'diffopt'|
opt.fillchars:append({ foldinner = "│" })                   -- Inner fold indicator. |'fillchars'|

-- Messages --

opt.shortmess:append({ W = true, I = true, c = true })  -- Suppress startup messages. |'shortmess'|

-- Diagnostics --
-- See |vim.diagnostic.config()| for all available options.
vim.diagnostic.config({
    virtual_text     = { spacing = 2, prefix = "●" },
    signs            = true,
    underline        = true,
    severity_sort    = true,
    update_in_insert = false,
})
