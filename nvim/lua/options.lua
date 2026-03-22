local opt = vim.opt

opt.termguicolors = true
opt.number = true
opt.relativenumber = true
opt.cursorline = true
opt.signcolumn = "yes"
opt.showmode = false
opt.conceallevel = 1

opt.tabstop = 4
opt.shiftwidth = 4
opt.expandtab = true
opt.breakindent = true
opt.list = true
opt.listchars = { tab = "│ ", trail = "·", nbsp = "␣" }

opt.ignorecase = true
opt.smartcase = true
opt.incsearch = true
opt.hlsearch = true
opt.maxsearchcount = 999

opt.inccommand = "split"
opt.wildmode = "longest:full,full"

opt.splitright = true
opt.splitbelow = true

opt.scrolloff = 8
opt.sidescrolloff = 8
opt.smoothscroll = true
opt.jumpoptions = "view"

opt.updatetime = 250
opt.timeoutlen = 500

opt.undofile = true
opt.clipboard = "unnamedplus"

opt.wrap = false
opt.foldlevel = 99
opt.shelltemp = false

opt.completeopt:append({ "nearest" })
opt.pummaxwidth = 80
opt.pumborder = "rounded"

opt.diffopt:append({ "indent-heuristic", "inline:char" })
opt.fillchars:append({ foldinner = "│" })

opt.shortmess:append({ W = true, I = true, c = true })

vim.diagnostic.config({
	virtual_text = { spacing = 2, prefix = "●" },
	signs = true,
	underline = true,
	severity_sort = true,
	update_in_insert = false,
})
