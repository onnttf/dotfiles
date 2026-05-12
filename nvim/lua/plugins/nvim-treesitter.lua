-- https://github.com/nvim-treesitter/nvim-treesitter
return {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
        local ts_config = require("nvim-treesitter.config")
        local parsers = require("nvim-treesitter.parsers")
        local install = require("nvim-treesitter.install").install

        -- Use treesitter for folds when LSP foldexpr is not active. |foldexpr|
        vim.api.nvim_create_autocmd("BufReadPost", {
            group = vim.api.nvim_create_augroup("ts_folds", { clear = true }),
            callback = function()
                if not vim.wo.foldexpr:find("lsp") then
                    vim.api.nvim_set_option_value("foldmethod", "expr", { win = 0 })
                    vim.api.nvim_set_option_value("foldexpr", "v:lua.vim.treesitter.foldexpr()", { win = 0 })
                end
            end,
        })

        -- Filetypes to skip for auto-install.
        local ignore_ft = {
            ["neo-tree"] = true,
            ["neo-tree-popup"] = true,
            ["neo-tree-preview"] = true,
            ["help"] = true,
            ["lazy"] = true,
            ["mason"] = true,
            ["checkhealth"] = true,
        }

        local installing = {}

        local function parser_installed(lang)
            return lang and lang ~= ""
                and #vim.api.nvim_get_runtime_file("parser/" .. lang .. ".*", false) > 0
        end

        local function should_install(buf, ft)
            if ignore_ft[ft] or vim.bo[buf].buftype ~= "" then return false end
            if vim.list_contains(ts_config.get_installed(), ft) then return false end
            if parser_installed(ft) then return false end
            if not parsers[ft] then return false end
            return true
        end

        -- Auto-install parser on first buffer open for an unrecognized filetype. |FileType|
        vim.api.nvim_create_autocmd("FileType", {
            group = vim.api.nvim_create_augroup("ts_auto_install", { clear = true }),
            callback = function(ev)
                if not should_install(ev.buf, ev.match) then return end
                local lang = vim.treesitter.language.get_lang(ev.match) or ev.match
                if installing[lang] then return end
                installing[lang] = true
                vim.schedule(function()
                    install({ lang }, { summary = false })
                    installing[lang] = nil
                    if vim.api.nvim_buf_is_loaded(ev.buf) then
                        pcall(vim.treesitter.start, ev.buf, lang)
                    end
                end)
            end,
        })

        -- Ensure essential parsers are always present. |TSInstall|
        local essentials = { "lua", "vim", "vimdoc", "query" }
        local installed = ts_config.get_installed()
        local missing = vim.tbl_filter(function(l) return not vim.list_contains(installed, l) end, essentials)
        if #missing > 0 then
            vim.schedule(function() install(missing, { summary = false }) end)
        end
    end,
}
