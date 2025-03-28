-- Set the leader keys to space
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Load settings, keymaps, commands, plugins, and LSP configs
require('option')
require('keymap')
require('autocommand')
require('plugin')
require('lsp')
