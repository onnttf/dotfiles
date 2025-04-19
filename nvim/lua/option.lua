local options = {
	number = true,
	mouse = "a",
	showmode = false,
	breakindent = true,
	ignorecase = true,
	smartcase = true,
	signcolumn = "yes",
	updatetime = 250,
	timeoutlen = 300,
	splitright = true,
	splitbelow = true,
	cursorline = true,
	scrolloff = 10,
	clipboard = "unnamedplus",
	list = true,
	listchars = {
		tab = "» ",
		trail = "·",
		nbsp = "␣",
	},
}

for k, v in pairs(options) do
	vim.opt[k] = v
end
