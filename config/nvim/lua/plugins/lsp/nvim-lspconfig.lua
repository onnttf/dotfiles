-- https://github.com/neovim/nvim-lspconfig
local lspconfig = require('lspconfig')
local capabilities = require('cmp_nvim_lsp').default_capabilities(vim.lsp.protocol.make_client_capabilities())
-- Function to define LSP mappings for a specific buffer
local on_attach = function(_, bufnr)
    local utils = require("utils.utils") -- Load 'utils' module here
    local nmap = function(keys, func, desc)
        if desc then
            desc = 'LSP: ' .. desc
        end
        utils.keymap('n', keys, func, {
            buffer = bufnr,
            desc = desc,
            silent = true
        })
    end
    nmap('K', vim.lsp.buf.hover, "Hover Documentation")
    nmap('gd', vim.lsp.buf.definition, '[G]oto [D]efinition')
    nmap('gr', vim.lsp.buf.references, '[G]oto [R]eferences')
    nmap('gt', vim.lsp.buf.type_definition, '[G]oto [T]ype Definition')
    nmap('gi', vim.lsp.buf.implementation, '[G]oto [I]mplementation')
    nmap('gs', vim.lsp.buf.signature_help, '[G]oto [S]ignature Documentation')
    nmap(']d', vim.diagnostic.goto_next, 'Go to next diagnostic message')
    nmap('[d', vim.diagnostic.goto_prev, 'Go to previous diagnostic message')
end

-- Enable language servers and set them up with the specified 'on_attach' and 'capabilities'
local servers = { "bashls", "lua_ls", "gopls", "sqlls", "jsonls", "yamlls", "tsserver", "intelephense" }
for _, lsp in ipairs(servers) do
    lspconfig[lsp].setup {
        on_attach = on_attach,
        capabilities = capabilities,
        settings = {
            gopls = {
                analyses = {
                    fieldalignment = true,
                    nilness = true,
                    shadow = true,
                    unusedparams = true,
                    unusedwrite = true,
                    useany = true,
                    unusedvariable = true
                },
                -- semanticTokens = true,
                -- staticcheck = true
                -- usePlaceholders = true
                -- allExperiments = true
            }
        }
    }
end
