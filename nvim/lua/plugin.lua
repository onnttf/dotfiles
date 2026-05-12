-- |plugin.lua| — lazy.nvim plugin manager bootstrap.

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not vim.uv.fs_stat(lazypath) then
	local out = vim.fn.system({
		"git", "clone", "--filter=blob:none", "--branch=stable",
		"https://github.com/folke/lazy.nvim.git", lazypath,
	})
	if vim.v.shell_error ~= 0 then error("Failed to clone lazy.nvim:\n" .. out) end
end
vim.opt.rtp:prepend(lazypath)

-- |require("lazy").setup()| — initialize lazy.nvim with plugin specs from lua/plugins/*.lua.
require("lazy").setup({
	spec = {
		{ import = "plugins" },
	},
	rocks = { enabled = false },
})
