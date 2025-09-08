local options = {
    number = true,
    mouse = "a",
    showmode = false,
    signcolumn = "yes",
    cursorline = true,
    scrolloff = 10,

    tabstop = 4,
    shiftwidth = 4,
    expandtab = true,
    breakindent = true,
    wrap = false,

    ignorecase = true,
    smartcase = true,
    incsearch = true,
    hlsearch = true,

    updatetime = 250,
    timeoutlen = 300,

    splitright = true,
    splitbelow = true,

    list = true,
    listchars = {
        tab = "» ",
        trail = "·",
        nbsp = "␣"
    },

    clipboard = "unnamedplus",

    foldmethod = "expr",
    foldexpr = "v:lua.vim.treesitter.foldexpr()",
    foldlevelstart = 99,
    foldenable = true
}

for k, v in pairs(options) do
    vim.opt[k] = v
end

vim.diagnostic.config({
    virtual_text = {
        enabled = true
    }
})
