local lsp2Config = {
    gopls = {
        cmd = { "gopls" },
        filetypes = { "go", "gomod", "gowork", "gotmpl" },
        settings = {}
    },
    sqlls = {
        cmd = { "sql-language-server", "up", "--method", "stdio" },
        filetypes = { "sql", "mysql" },
        settings = {}
    },
    pyright = {
        cmd = { "pyright-langserver", "--stdio" },
        filetypes = { "python" },
        settings = {}
    },
    lua_ls = {
        cmd = { "lua-language-server" },
        filetypes = { "lua" },
        settings = {}
    },
    intelephense = {
        cmd = { "intelephense", "--stdio" },
        filetypes = { "php" },
        settings = {}
    },
    jsonls = {
        cmd = { "vscode-json-language-server", "--stdio" },
        filetypes = { "json", "jsonc" },
        settings = {}
    },
    yamlls = {
        cmd = { "yaml-language-server", "--stdio" },
        filetypes = { "yaml", "yaml.docker-compose", "yaml.gitlab" },
        settings = {}
    },
    bashls = {
        cmd = { "bash-language-server", "start" },
        filetypes = { "bash", "sh" },
        settings = {}
    }
}

vim.lsp.config('*', {
    capabilities = {
        textDocument = {
            semanticTokens = {
                multilineTokenSupport = true
            }
        }
    },
    root_markers = { '.git' }
})

for lsp, config in pairs(lsp2Config) do
    local lsp_config = {}

    if config.cmd and next(config.cmd) then
        lsp_config.cmd = config.cmd
    end
    if config.filetypes and next(config.filetypes) then
        lsp_config.filetypes = config.filetypes
    end
    if config.settings and next(config.settings) then
        lsp_config.settings = config.settings
    end

    vim.lsp.config[lsp] = lsp_config
    vim.lsp.enable({ lsp })
end

local augroup = vim.api.nvim_create_augroup("user_config_lsp", {
    clear = true
})

vim.api.nvim_create_autocmd('LspAttach', {
    group = augroup,
    callback = function(args)
        local client = assert(vim.lsp.get_client_by_id(args.data.client_id))

        local keymap = require("util").keymap

        if client:supports_method('textDocument/hover') then
            keymap('n', 'K', function()
                vim.lsp.buf.hover({
                    border = 'rounded',
                    max_height = 10
                })
            end, {
                buffer = args.buf,
                desc = "Show hover documentation"
            })
        end

        if client:supports_method('textDocument/codeAction') then
            keymap('n', 'gra', '<Cmd>FzfLua lsp_code_actions previewer=false<CR>', {
                buffer = args.buf,
                desc = "Show code actions"
            })
        end

        if client:supports_method('textDocument/definition') then
            keymap('n', 'gd', '<Cmd>FzfLua lsp_definitions<CR>', {
                buffer = args.buf,
                desc = "Go to definition"
            })
        end

        if client:supports_method('textDocument/implementation') then
            keymap('n', 'gi', '<Cmd>FzfLua lsp_implementations<CR>', {
                buffer = args.buf,
                desc = "Go to implementation"
            })
        end

        if client:supports_method('textDocument/typeDefinition') then
            keymap('n', 'gy', '<Cmd>FzfLua lsp_typedefs<CR>', {
                buffer = args.buf,
                desc = "Go to type definition"
            })
        end

        if client:supports_method('textDocument/documentSymbol') then
            keymap('n', 'gO', '<Cmd>FzfLua lsp_document_symbols previewer=false<CR>', {
                buffer = args.buf,
                desc = "Show document symbols"
            })
        end

        if client:supports_method('textDocument/references') then
            keymap('n', 'gr', '<Cmd>FzfLua lsp_references<CR>', {
                buffer = args.buf,
                desc = "Show references"
            })
        end

        if client:supports_method('callHierarchy/incomingCalls') then
            keymap('n', 'g(', '<Cmd>FzfLua lsp_incoming_calls<CR>', {
                buffer = args.buf,
                desc = "Show incoming calls"
            })
        end

        if client:supports_method('callHierarchy/outgoingCalls') then
            keymap('n', 'g)', '<Cmd>FzfLua lsp_outgoing_calls<CR>', {
                buffer = args.buf,
                desc = "Show outgoing calls"
            })
        end

        if client:supports_method('textDocument/highlight') then
            vim.cmd([[
              autocmd CursorHold  <buffer> lua vim.lsp.buf.document_highlight()
              autocmd CursorHoldI <buffer> lua vim.lsp.buf.document_highlight()
              autocmd CursorMoved <buffer> lua vim.lsp.buf.clear_references()
            ]])
        end
    end
})
