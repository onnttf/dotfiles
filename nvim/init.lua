vim.g.mapleader = " "
vim.g.maplocalleader = " "

local modules = { "option", "keymap", "autocommand", "plugin", "lsp" }

for _, module in ipairs(modules) do
	local ok, err = pcall(require, module)
	if not ok then
		vim.notify("Error loading module '" .. module .. "': " .. err, vim.log.levels.ERROR)
	end
end
