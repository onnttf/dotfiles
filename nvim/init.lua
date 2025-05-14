-- Set the leader keys to space
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Load settings, keymaps, commands, plugins, and LSP configs
require("option")
require("autocommand")
require("plugin")
require("keymap")
require("lsp")
