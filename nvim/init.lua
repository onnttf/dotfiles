vim.g.mapleader = " "
vim.g.maplocalleader = " "

require("options")
require("plugin")
require("autocmds")
require("keymaps")

-- Deferred via |vim.schedule()| to ensure plugins (blink.cmp, conform)
-- are fully loaded before LSP configuration runs.
vim.schedule(function()
	require("lsp")
end)
