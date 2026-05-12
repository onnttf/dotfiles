-- |lsp.lua| — LSP server configuration.

local on_attach = function(client, bufnr)
    local function map(mode, lhs, rhs, desc)
        vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, silent = true, noremap = true, desc = desc })
    end
    local function supports(method)
        return client:supports_method(method)
    end

    -- Navigation. |vim.lsp.buf.definition()| |vim.lsp.buf.declaration()|
    if supports("textDocument/definition") then map("n", "gd", vim.lsp.buf.definition, "Go to definition") end
    if supports("textDocument/declaration") then map("n", "gD", vim.lsp.buf.declaration, "Go to declaration") end
    if supports("textDocument/implementation") then map("n", "gri", vim.lsp.buf.implementation, "Go to implementation") end
    if supports("textDocument/typeDefinition") then map("n", "grt", vim.lsp.buf.type_definition, "Go to type definition") end
    if supports("textDocument/references") then map("n", "grr", vim.lsp.buf.references, "List references") end

    -- Hover and signature help. |vim.lsp.buf.hover()| |vim.lsp.buf.signature_help()|
    if supports("textDocument/hover") then map("n", "K", vim.lsp.buf.hover, "Hover") end
    if supports("textDocument/signatureHelp") then map("i", "<C-s>", vim.lsp.buf.signature_help, "Signature help") end

    -- Code actions. |vim.lsp.buf.rename()| |vim.lsp.buf.code_action()|
    if supports("textDocument/rename") then map({ "n", "v" }, "grn", vim.lsp.buf.rename, "Rename") end
    if supports("textDocument/codeAction") then map({ "n", "v" }, "gra", vim.lsp.buf.code_action, "Code action") end
    if supports("textDocument/codeLens") then map("n", "grx", vim.lsp.codelens.run, "Run code lens") end

    -- Symbols. |vim.lsp.buf.document_symbol()| |vim.lsp.buf.workspace_symbol()|
    if supports("textDocument/documentSymbol") then map("n", "gO", vim.lsp.buf.document_symbol, "Document symbols") end
    if supports("workspace/symbol") then map("n", "<leader>ls", vim.lsp.buf.workspace_symbol, "Workspace symbols") end

    -- Inlay hints. |vim.lsp.inlay_hint|
    if supports("textDocument/inlayHint") then
        map("n", "<leader>lh", function()
            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr }), { bufnr = bufnr })
        end, "Toggle inlay hints")
    end

    -- Call hierarchy. |vim.lsp.buf.incoming_calls()| |vim.lsp.buf.outgoing_calls()|
    if supports("callHierarchy/incomingCalls") then map("n", "<leader>li", vim.lsp.buf.incoming_calls, "Incoming calls") end
    if supports("callHierarchy/outgoingCalls") then map("n", "<leader>lo", vim.lsp.buf.outgoing_calls, "Outgoing calls") end

    -- Type hierarchy. |vim.lsp.buf.typehierarchy()|
    if supports("textDocument/prepareTypeHierarchy") then
        map("n", "<leader>lt", function()
            vim.ui.select({ "supertypes", "subtypes" }, { prompt = "Type hierarchy:", kind = "typehierarchy" },
                function(kind)
                    if kind then vim.lsp.buf.typehierarchy(kind) end
                end)
        end, "Type hierarchy")
    end

    -- Incremental selection via LSP. |lsp-selectionRange|
    if supports("textDocument/selectionRange") then
        map("v", "an", "an", "Select outer node")
        map("v", "in", "in", "Select inner node")
    end

    -- LSP folding. Closes import blocks on open. |vim.lsp.foldexpr()| |vim.lsp.foldclose()|
    if supports("textDocument/foldingRange") then
        vim.wo[0].foldmethod = "expr"
        vim.wo[0].foldexpr   = "v:lua.vim.lsp.foldexpr()"
        vim.api.nvim_create_autocmd("LspNotify", {
            buffer = bufnr,
            callback = function(ev)
                if ev.data.method == "textDocument/didOpen" then
                    vim.lsp.foldclose("imports", vim.fn.bufwinid(bufnr))
                end
            end,
        })
    end

    -- Highlight references on cursor hold. |vim.lsp.buf.document_highlight()|
    if supports("textDocument/documentHighlight") then
        vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
            buffer   = bufnr,
            callback = vim.lsp.buf.document_highlight,
        })
        vim.api.nvim_create_autocmd("CursorMoved", {
            buffer   = bufnr,
            callback = vim.lsp.buf.clear_references,
        })
    end

    -- Diagnostic navigation. |vim.diagnostic.jump()|
    map("n", "[d", function() vim.diagnostic.jump({ count = -1 }) end, "Prev diagnostic")
    map("n", "]d", function() vim.diagnostic.jump({ count = 1 }) end, "Next diagnostic")
    map("n", "[D", function() vim.diagnostic.jump({ count = -math.huge, wrap = false }) end, "First diagnostic")
    map("n", "]D", function() vim.diagnostic.jump({ count = math.huge, wrap = false }) end, "Last diagnostic")
    map("n", "[e", function() vim.diagnostic.jump({ count = -1, severity = { min = vim.diagnostic.severity.ERROR } }) end,
        "Prev error")
    map("n", "]e", function() vim.diagnostic.jump({ count = 1, severity = { min = vim.diagnostic.severity.ERROR } }) end,
        "Next error")
    map("n", "[w", function() vim.diagnostic.jump({ count = -1, severity = { min = vim.diagnostic.severity.WARN } }) end,
        "Prev warning")
    map("n", "]w", function() vim.diagnostic.jump({ count = 1, severity = { min = vim.diagnostic.severity.WARN } }) end,
        "Next warning")

    -- Diagnostic actions. |vim.diagnostic|
    map("n", "<leader>xo", vim.diagnostic.open_float, "Show diagnostics")
    map("n", "<leader>xl", vim.diagnostic.setloclist, "Diagnostics location list")
    map("n", "<leader>xq", vim.diagnostic.setqflist, "Diagnostics quickfix list")
    if supports("workspace/diagnostic") then
        map("n", "<leader>xw", vim.lsp.buf.workspace_diagnostics, "Workspace diagnostics")
    end
end

-- =====================================================================
-- LSP server registration and formatter configuration.
-- =====================================================================

-- Mason package names that differ from the LSP server binary name. |mason-registry|
local server_to_mason = {
    ts_ls    = "ts-ls",
    json_lsp = "vscode-json-language-server",
    bashls   = "bash-language-server",
}

-- Formatters applied to all filetypes via |conform|.
local global_formatters = { "codespell" }

-- Merge two LSP configs; list fields are concatenated and deduplicated.
local function merge_lsp(a, b)
    return vim.tbl_deep_extend(function(_, va, vb)
        if vim.islist(va) and vim.islist(vb) then
            return vim.list.unique(vim.list_extend(vim.list_extend({}, va), vb))
        end
        return vb
    end, a, b)
end

-- Map filetype to its language config module. Multiple filetypes may share one.
local lang_map = {
    go              = "lang.go",
    gomod           = "lang.gomod",
    gowork          = "lang.gowork",
    gotmpl          = "lang.gotmpl",
    python          = "lang.python",
    javascript      = "lang.typescript",
    javascriptreact = "lang.typescript",
    typescript      = "lang.typescript",
    typescriptreact = "lang.typescript",
    lua             = "lang.lua",
    json            = "lang.json",
    jsonc           = "lang.json",
    yaml            = "lang.yaml",
    bash            = "lang.bash",
    sh              = "lang.bash",
}

-- Inherit blink.cmp completion capabilities for all LSP servers.
-- See |require("blink.cmp").get_lsp_capabilities()|
local capabilities = require("blink.cmp").get_lsp_capabilities()
vim.lsp.config("*", { on_attach = on_attach, capabilities = capabilities })

-- Accumulate per-server LSP configs and per-filetype formatters.
local lsp_config = {}
local ft_formatters = {}

-- Load each language module and merge server configs.
for ft, mod in pairs(lang_map) do
    local cfg = require(mod)
    if cfg.lsp then
        local server = cfg.lsp.server
        if not lsp_config[server] then
            lsp_config[server] = vim.tbl_deep_extend("force", {}, cfg.lsp)
        else
            lsp_config[server] = merge_lsp(lsp_config[server], cfg.lsp)
        end
        lsp_config[server].filetypes = vim.list_extend(lsp_config[server].filetypes or {}, { ft })
    end
    if cfg.formatter then ft_formatters[ft] = cfg.formatter end
end

-- Register each LSP server with its merged config and enabled filetypes.
for server, cfg in pairs(lsp_config) do
    cfg.filetypes = vim.list.unique(cfg.filetypes)
    vim.lsp.config(server, cfg)
    vim.lsp.enable(server)
end

-- Register formatters with conform.nvim. |conform.formatters_by_ft|
local ok, conform = pcall(require, "conform")
if ok then
    conform.formatters_by_ft["*"] = global_formatters
    for ft, formatters in pairs(ft_formatters) do
        conform.formatters_by_ft[ft] = formatters
    end
end

-- =====================================================================
-- |MasonInstallAll| — Auto-install all configured LSP and formatter tools.
-- =====================================================================
local mason_tools = vim.list_extend({}, global_formatters)
for server, _ in pairs(lsp_config) do
    table.insert(mason_tools, server_to_mason[server] or server)
end
for _, formatters in pairs(ft_formatters) do
    vim.list_extend(mason_tools, formatters)
end
mason_tools = vim.list.unique(mason_tools)

vim.api.nvim_create_user_command("MasonInstallAll", function()
    local registry = require("mason-registry")
    registry.refresh(function()
        local missing = {}
        for _, tool in ipairs(mason_tools) do
            local ok, pkg = pcall(registry.get_package, tool)
            if ok and pkg and not pkg:is_installed() then table.insert(missing, tool) end
        end
        if #missing > 0 then
            vim.notify("Installing: " .. table.concat(missing, ", "), vim.log.levels.INFO)
            vim.cmd("MasonInstall " .. table.concat(missing, " "))
        else
            vim.notify("All Mason tools are already installed.", vim.log.levels.INFO)
        end
    end)
end, { desc = "Install all configured LSP/formatter tools via Mason" })
