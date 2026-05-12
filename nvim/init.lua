-- |init.lua| — Neovim entry point.

vim.g.mapleader      = " "
vim.g.maplocalleader = " "

require("options")
require("plugin") -- lazy.nvim bootstrap (loads lua/plugins/*.lua)
require("autocmds")
require("keymaps")

-- Defer LSP setup until all plugins (blink.cmp, conform) are loaded.
-- |vim.schedule()| ensures the event loop processes plugin setup first.
vim.schedule(function() require("lsp") end)
