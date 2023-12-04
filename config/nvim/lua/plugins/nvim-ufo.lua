-- https://github.com/kevinhwang91/nvim-ufo
-- '0' is not bad
vim.o.foldcolumn = '0'
-- Using ufo provider need a large value, feel free to decrease the value
vim.o.foldlevel = 99
vim.o.foldlevelstart = 99
vim.o.foldenable = true

local function customizeSelector(bufnr)
    local function handleFallbackException(err, providerName)
        if type(err) == 'string' and err:match('UfoFallbackException') then
            return require('ufo').getFolds(bufnr, providerName)
        else
            return require('promise').reject(err)
        end
    end

    return require('ufo').getFolds(bufnr, 'lsp'):catch(function(err)
        return handleFallbackException(err, 'treesitter')
    end):catch(function(err)
        return handleFallbackException(err, 'indent')
    end)
end

require('ufo').setup({
    provider_selector = function(bufnr, filetype, buftype)
        return customizeSelector
        -- return {'treesitter', 'indent'}
    end
})

local utils = require("utils.utils") -- Load 'utils' module here

-- Using ufo provider need remap `zR` and `zM`. If Neovim is 0.6.1, remap yourself
utils.keymap('n', 'zR', require('ufo').openAllFolds)
utils.keymap('n', 'zM', require('ufo').closeAllFolds)
