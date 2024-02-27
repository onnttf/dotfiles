-- https://github.com/neovim/nvim-lspconfig

-- Importing necessary modules
local lspconfig = require("lspconfig")

local capabilities = require("cmp_nvim_lsp").default_capabilities(vim.lsp.protocol.make_client_capabilities())

-- Function to handle key mappings for LSP
local on_attach = function(_, bufnr)
  local utils = require("utils.utils")

  -- Function to create LSP key mappings
  local nmap = function(keys, func, desc)
    desc = desc and ("LSP: " .. desc) or nil
    utils.keymap("n", keys, func, {
      buffer = bufnr,
      desc = desc,
      silent = true,
    })
  end

  -- LSP key mappings
  nmap("K", vim.lsp.buf.hover, "Hover Documentation")
  nmap("gd", vim.lsp.buf.definition, "[G]oto [D]efinition")
  nmap("gr", vim.lsp.buf.references, "[G]oto [R]eferences")
  nmap("D", vim.lsp.buf.type_definition, "Type [D]efinition")
  nmap("gi", vim.lsp.buf.implementation, "[G]oto [I]mplementation")
  nmap("]d", vim.diagnostic.goto_next, "Go to next [D]iagnostic message")
  nmap("[d", vim.diagnostic.goto_prev, "Go to previous [D]iagnostic message")
end

-- LSP servers configuration
local servers = {
  bashls = {},
  lua_ls = {},
  gopls = {
    setting = {
      gopls = {
        analyses = {
          fieldalignment = true,
          nilness = true,
          shadow = true,
          unusedparams = true,
          unusedwrite = true,
          useany = true,
          unusedvariable = true,
        },
        -- semanticTokens = true,
        -- staticcheck = true
        -- usePlaceholders = true
        -- allExperiments = true
      },
    },
  },
  sqlls = {},
  jsonls = {},
  yamlls = {},
  tsserver = {},
  intelephense = {},
}

-- Mason setup
require("mason").setup()

-- Ensure installation of necessary tools
local ensure_installed = vim.tbl_keys(servers or {})
vim.list_extend(ensure_installed, {
  "stylua", -- Add other tools as needed
})
require("mason-tool-installer").setup({ ensure_installed = ensure_installed })

-- Setup LSP with Mason
require("mason-lspconfig").setup({
  handlers = {
    function(server_name)
      local server = servers[server_name] or {}
      -- Configure LSP servers
      require("lspconfig")[server_name].setup({
        on_attach = on_attach,
        capabilities = capabilities,
        cmd = server.cmd,
        settings = server.settings,
        filetypes = server.filetypes,
      })
    end,
  },
})
