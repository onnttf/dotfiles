local has_words_before = function()
    unpack = unpack or table.unpack
    local line, col = unpack(vim.api.nvim_win_get_cursor(0))
    return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

local feedkey = function(key, mode)
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(key, true, true, true), mode, true)
end

local cmp = require 'cmp'
cmp.setup({
    enabled = function()
        -- Disable completion in comments
        local context = require 'cmp.config.context'
        -- Keep command mode completion enabled when cursor is in a comment
        if vim.api.nvim_get_mode().mode == 'c' then
            return true
        else
            return not context.in_treesitter_capture("comment") and not context.in_syntax_group("Comment")
        end
    end,
    preselect = cmp.PreselectMode.None,
    matching = {
        -- Disable fuzzy matching
        disallow_fuzzy_matching = true,
        -- Disable full-fuzzy matching
        disallow_fullfuzzy_matching = true,
        -- Disable fuzzy matching without prefix matching
        disallow_partial_fuzzy_matching = true,
        -- Disable partial matching
        disallow_partial_matching = true,
        -- Allow prefix unmatching
        disallow_prefix_unmatching = false
    },
    snippet = {
        expand = function(args)
            -- Expand snippets for `vsnip` users
            vim.fn["vsnip#anonymous"](args.body)
        end
    },
    mapping = {
        -- Key mappings for completion
        ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_next_item()
            elseif vim.fn["vsnip#available"](1) == 1 then
                feedkey("<Plug>(vsnip-expand-or-jump)", "")
            elseif has_words_before() then
                cmp.complete()
            else
                -- The fallback function sends a already mapped key. In this case, it's probably `<Tab>`.
                fallback()
            end
        end, { "i", "s" }),
        ["<S-Tab>"] = cmp.mapping(function()
            if cmp.visible() then
                cmp.select_prev_item()
            elseif vim.fn["vsnip#jumpable"](-1) == 1 then
                feedkey("<Plug>(vsnip-jump-prev)", "")
            end
        end, { "i", "s" }),
        ["<CR>"] = cmp.mapping({
            i = function(fallback)
                if cmp.visible() and cmp.get_active_entry() then
                    cmp.confirm({
                        behavior = cmp.ConfirmBehavior.Replace,
                        select = false
                    })
                else
                    fallback()
                end
            end
            -- s = cmp.mapping.confirm({
            --     select = false
            -- }),
            -- c = cmp.mapping.confirm({
            --     behavior = cmp.ConfirmBehavior.Replace,
            --     select = false
            -- })
        })
    },
    sources = cmp.config.sources({ {
        name = 'nvim_lsp'
    }, {
        name = 'vsnip'
    }, {
        name = 'buffer'
    }, {
        name = 'path'
    } })
})

-- `/` cmdline setup.
cmp.setup.cmdline('/', {
    mapping = cmp.mapping.preset.cmdline(),
    completion = {
        autocomplete = false
    },
    sources = { {
        name = 'buffer'
    } }
})

-- `:` cmdline setup.
cmp.setup.cmdline(':', {
    mapping = cmp.mapping.preset.cmdline(),
    completion = {
        autocomplete = false
    },
    enabled = function()
        -- Set of commands where cmp will be disabled
        local disabled = {
            IncRename = true,
            -- :substitute
            s = true,
            -- :substitute (magic)
            sm = true
        }
        -- Get the first word of the cmdline
        local cmd = vim.fn.getcmdline():match("%S+")
        -- Return true if the cmd isn't disabled, else call/return cmp.close() to disable completion
        return not disabled[cmd] or cmp.close()
    end,
    sources = cmp.config.sources({ {
        name = 'path'
    } }, { {
        name = 'cmdline',
        option = {
            ignore_cmds = { 'Man', '!' }
        }
    } })
})

-- Add parentheses after selecting function or method item
-- If you want insert `(` after select function or method item
local cmp_autopairs = require('nvim-autopairs.completion.cmp')
cmp.event:on('confirm_done', cmp_autopairs.on_confirm_done())
