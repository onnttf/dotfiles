local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system(
        { "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable", -- latest stable release
            lazypath }
    )
end
vim.opt.rtp:prepend(lazypath)

local lsp = require("plugins/lsp/init")

local plugins = {
    {
        "projekt0n/github-nvim-theme",
        lazy = false,    -- make sure we load this during startup if it is your main colorscheme
        priority = 1000, -- make sure to load this before all the other start plugins
        config = function()
            -- load the colorscheme here
            require("plugins/github-nvim-theme")
        end
    },
    {
        'glepnir/dashboard-nvim',
        dependencies = { 'nvim-tree/nvim-web-devicons' },
        event = 'VimEnter',
        config = function()
            require("plugins/dashboard-nvim")
        end
    },
    {
        "nvim-neo-tree/neo-tree.nvim",
        branch = "v3.x",
        dependencies = { "nvim-lua/plenary.nvim", "nvim-tree/nvim-web-devicons", "MunifTanjim/nui.nvim" },
        -- cmd = {"NeoTreeRevealToggle", "NeoTreeFloatToggle"},
        event = "VeryLazy",
        config = function()
            require("plugins/neo-tree")
        end
    },
    {
        'nvim-telescope/telescope.nvim',
        dependencies = {
            'nvim-lua/plenary.nvim',
            {
                'nvim-telescope/telescope-fzf-native.nvim',
                build = 'make'
            }
        },
        -- cmd = "Telescope",
        event = "VeryLazy",
        config = function()
            require("plugins/telescope")
        end
    },
    {
        'lewis6991/gitsigns.nvim',
        cmd = "Gitsigns",
        config = function()
            require("plugins/gitsigns")
        end
    },
    {
        'nvim-treesitter/nvim-treesitter',
        event = "VeryLazy",
        build = ":TSUpdate",
        config = function()
            require("plugins/nvim-treesitter")
        end
    },
    {
        "lukas-reineke/indent-blankline.nvim",
        main = "ibl",
        event = "VeryLazy",
        config = function()
            require("plugins.indent-blankline")
        end
    },
    {
        "kevinhwang91/nvim-ufo",
        dependencies = { 'kevinhwang91/promise-async', 'nvim-treesitter/nvim-treesitter' },
        event = "VeryLazy",
        config = function()
            require("plugins/nvim-ufo")
        end
    },
    {
        "folke/trouble.nvim",
        dependencies = { 'nvim-tree/nvim-web-devicons' },
        cmd = "Trouble",
        config = function()
            require("plugins.trouble")
        end
    },
    {
        "folke/which-key.nvim",
        event = "VeryLazy",
        opts = {
            -- your configuration comes here
            -- or leave it empty to use the default settings
            -- refer to the configuration section below
        }
    },
    {
        "nvimtools/none-ls.nvim",
        config = function()
            require("plugins.none-ls")
        end,
        requires = { "nvim-lua/plenary.nvim" },
    },
    lsp
}
require("lazy").setup(plugins)
