-- https://github.com/nvimtools/none-ls.nvim
local null_ls = require("null-ls")

-- Function to trigger LSP formatting for a specific buffer
local lsp_formatting = function(bufnr)
    vim.lsp.buf.format({
        filter = function(client)
            -- Apply logic to select only the "null-ls" client for formatting
            return client.name == "null-ls"
        end,
        bufnr = bufnr,
    })
end

-- Create an autogroup for LSP formatting events
local augroup = vim.api.nvim_create_augroup("LspFormatting", {})

-- Add the formatting on save callback to your shared on_attach callback
local on_attach = function(client, bufnr)
    if client.supports_method("textDocument/formatting") then
        -- Clear existing autocommands for the buffer
        vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })

        -- Create a new autocommand for BufWritePre event to trigger LSP formatting
        vim.api.nvim_create_autocmd("BufWritePre", {
            group = augroup,
            buffer = bufnr,
            callback = function()
                lsp_formatting(bufnr)
            end,
        })
    end
end

-- Setup null-ls with specified sources and on_attach callback
require("null-ls").setup {
    sources = {
        -- Code Actions
        -- Completion
        -- Diagnostics
        null_ls.builtins.diagnostics.golangci_lint,
        -- Formatting
        null_ls.builtins.formatting.prettier,
        null_ls.builtins.formatting.gofumpt,
        null_ls.builtins.formatting.goimports,
        -- Hover
    },
    on_attach = on_attach
}
