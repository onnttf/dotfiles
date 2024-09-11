local configs = require("nvim-treesitter.configs")

-- List of parsers to ensure are installed
local ensure_installed = {
    "bash", "vim", "vimdoc", "lua", "go", "php", "sql",
    "html", "javascript", "css", "vue", "json", "yaml",
    "markdown", "dockerfile",
}

-- Function to disable highlighting for large files
local function disable_large_files(lang, buf)
    local max_filesize = 100 * 1024 -- 100 KB
    local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
    if ok and stats and stats.size > max_filesize then
        return true
    end
end

configs.setup({
    -- Automatically install missing parsers when entering buffer
    auto_install = true,

    -- List of parsers to install
    ensure_installed = ensure_installed,

    -- Highlighting configuration
    highlight = {
        enable = true,
        disable = disable_large_files,
        additional_vim_regex_highlighting = false,
    },

    -- Indentation based on treesitter for the = operator
    indent = { enable = true },

    -- Uncomment and adjust the following section if you want to use incremental selection
    -- incremental_selection = {
    --     enable = true,
    --     keymaps = {
    --         init_selection = "<CR>",
    --         node_incremental = "<CR>",
    --         node_decremental = "<BS>",
    --         scope_incremental = "<Tab>",
    --     },
    -- },

    -- You can add more modules here, such as:
    -- textobjects = {
    --     -- Your textobjects configuration
    -- },
    -- context = {
    --     -- Your context configuration
    -- },
})
