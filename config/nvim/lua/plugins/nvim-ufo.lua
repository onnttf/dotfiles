-- https://github.com/kevinhwang91/nvim-ufo
-- Set foldcolumn to '0' for a cleaner appearance
vim.o.foldcolumn = "0"

-- Configure fold settings for UFO provider
vim.o.foldlevel = 99
vim.o.foldlevelstart = 99
vim.o.foldenable = true

-- Customize fold provider selection logic
local function customizeSelector(bufnr)
	local function handleFallbackException(err, providerName)
		if type(err) == "string" and err:match("UfoFallbackException") then
			return require("ufo").getFolds(bufnr, providerName)
		else
			return require("promise").reject(err)
		end
	end

	return require("ufo")
		.getFolds(bufnr, "lsp")
		:catch(function(err)
			return handleFallbackException(err, "treesitter")
		end)
		:catch(function(err)
			return handleFallbackException(err, "indent")
		end)
end

-- Setup UFO with customized provider selection logic
require("ufo").setup({
	provider_selector = function(bufnr, filetype, buftype)
		return customizeSelector
		-- Alternatively, you can manually specify providers like:
		-- return {'treesitter', 'indent'}
	end,
})

-- Load 'utils' module here
local utils = require("utils.utils")
-- Remap 'zR' and 'zM' to open and close all folds when using UFO provider
-- utils.keymap("n", "zR", require("ufo").openAllFolds)
-- utils.keymap("n", "zM", require("ufo").closeAllFolds)
