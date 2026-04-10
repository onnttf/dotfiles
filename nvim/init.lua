-- Entry point. Sets |<leader>| before loading modules in dependency order.
vim.g.mapleader      = " "
vim.g.maplocalleader = " "

require("option")
require("plugin")
require("autocommand")
require("keymap")
require("filetype-config")
