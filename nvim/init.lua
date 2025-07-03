-- [[ Neovim Configuration Entry Point ]]

-- Set leader key
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Enable true colors for proper colorscheme display.
vim.opt.termguicolors = true

-- Load core Neovim configurations in a logical order.
require("option") -- Load general editor options.
require("plugin") -- Install and configure plugins via lazy.nvim.
require("autocommand") -- Load autocommands for event-driven actions.
require("keymap") -- Load global and plugin-specific keybindings.
require("lsp") -- Configure Language Server Protocol (LSP).
