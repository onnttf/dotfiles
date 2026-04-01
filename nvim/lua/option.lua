local options = {
	number = true,      -- 'number': show line numbers (:h number)
	mouse = "a",        -- 'mouse': enable mouse in all modes (:h mouse)
	showmode = false,   -- 'showmode': suppress -- INSERT -- etc., mode shown in statusline
	signcolumn = "yes", -- 'signcolumn': always show; prevents layout shift (:h signcolumn)
	cursorline = true,  -- 'cursorline': highlight the line the cursor is on (:h cursorline)
	shelltemp = true,   -- 'shelltemp': use temp files for shell commands (:h shelltemp, 0.12 default changed)
}

options.scrolloff = 8      -- 'scrolloff': lines of context above/below cursor (:h scrolloff)
options.sidescrolloff = 8  -- 'sidescrolloff': columns of context left/right of cursor

options.tabstop = 4        -- 'tabstop': number of spaces a <Tab> counts for (:h tabstop)
options.shiftwidth = 4     -- 'shiftwidth': spaces used for each step of (auto)indent
options.expandtab = true   -- 'expandtab': insert spaces instead of a <Tab> character
options.breakindent = true -- 'breakindent': wrapped lines preserve indentation visually

options.wrap = false       -- 'wrap': disable soft line wrapping
options.list = true        -- 'list': show 'listchars' markers for whitespace (:h listchars)
options.listchars = {
	tab = "│ ",
	trail = "·",
	nbsp = "␣",
}

options.ignorecase = true  -- 'ignorecase': case-insensitive search patterns (:h ignorecase)
options.smartcase = true   -- 'smartcase': override ignorecase when pattern has uppercase
options.incsearch = true   -- 'incsearch': show partial match as you type (:h incsearch)
options.hlsearch = true    -- 'hlsearch': highlight all matches of last search

options.updatetime = 250   -- 'updatetime': ms idle before CursorHold fires and swap writes
options.timeoutlen = 500   -- 'timeoutlen': ms to wait for mapped key sequence to complete

options.splitright = true  -- 'splitright': :vsplit opens new window to the right
options.splitbelow = true  -- 'splitbelow': :split opens new window below

for k, v in pairs(options) do
	vim.opt[k] = v
end

if vim.fn.has("clipboard") == 1 then
	vim.opt.clipboard = "unnamedplus" -- 'clipboard': sync unnamed register with system clipboard
end

vim.o.winborder = "rounded" -- 'winborder': default border style for all floating windows (0.12+)

-- vim.diagnostic.config: control virtual text, signs, and update behaviour (:h vim.diagnostic)
vim.diagnostic.config({
	virtual_text = {
		spacing = 2,
		prefix = "●",
	},
	signs = true,
	underline = true,
	severity_sort = true,
	update_in_insert = false,
})
