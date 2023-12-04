-- https://github.com/lukas-reineke/indent-blankline.nvim
local exclude_ft = { "help", "git", "markdown", "snippets", "text", "gitconfig", "alpha", "dashboard" }

require("ibl").setup {
    exclude = {
        filetypes = exclude_ft,
        buftypes = { "terminal" },
    }
}
