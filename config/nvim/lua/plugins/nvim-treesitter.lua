-- https://github.com/nvim-treesitter/nvim-treesitter
require 'nvim-treesitter.configs'.setup({
    -- a list of parser names, or "all" (the four listed parsers should always be installed)
    -- https://github.com/nvim-treesitter/nvim-treesitter#supported-languages
    ensure_installed = {
        "bash", "vim", "lua", "go", "sql", "php", "javascript", "vue", "css", "json", "yaml", "markdown", "dockerfile"
    },
    highlight = {
        enable = true,
        disable = function(lang, buf)
            local max_filesize = 100 * 1024 -- 100 KB
            local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
            if ok and stats and stats.size > max_filesize then
                return true
            end
        end,
        -- setting this to true will run `:h syntax` and tree-sitter at the same time.
        -- set this to `true` if you depend on 'syntax' being enabled (like for indentation).
        -- using this option may slow down your editor, and you may see some duplicate highlights.
        -- instead of true it can also be a list of languages
        additional_vim_regex_highlighting = false
    },
    incremental_selection = {
        enable = true,
        keymaps = {
            init_selection = "<CR>",
            node_incremental = "<CR>",
            node_decremental = "<BS>",
            scope_incremental = "<Tab>",
        },
    },
})
