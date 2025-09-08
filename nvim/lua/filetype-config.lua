local filetype_config = {
    ["*"] = {
        formatter = {"codespell"}
    },
    go = {
        lsp = {
            server = "gopls",
            cmd = {"gopls"},
            root_markers = {"go.work", "go.mod", ".git"}
        },
        formatter = {"goimports", "gofumpt"}
    },
    gomod = {
        lsp = {
            server = "gopls"
        },
        formatter = {"goimports"}
    },
    gowork = {
        lsp = {
            server = "gopls"
        },
        formatter = {"goimports"}
    },
    gotmpl = {
        lsp = {
            server = "gopls"
        },
        formatter = {"goimports"}
    },
    python = {
        lsp = {
            server = "pyright",
            cmd = {"pyright-langserver", "--stdio"}
        },
        formatter = {"black"}
    },
    lua = {
        lsp = {
            server = "lua-language-server",
            cmd = {"lua-language-server"}
        },
        formatter = {"stylua"}
    },
    json = {
        lsp = {
            server = "jsonls",
            cmd = {"vscode-json-language-server", "--stdio"}
        },
        formatter = {"prettier"}
    },
    jsonc = {
        lsp = {
            server = "jsonls"
        },
        formatter = {"prettier"}
    },
    yaml = {
        lsp = {
            server = "yamlls",
            cmd = {"yaml-language-server", "--stdio"}
        },
        formatter = {"prettier"}
    },
    bash = {
        lsp = {
            server = "bashls",
            cmd = {"bash-language-server", "start"}
        },
        formatter = {"shfmt"}
    },
    sh = {
        lsp = {
            server = "bashls"
        },
        formatter = {"shfmt"}
    }
}

for ft, cfg in pairs(filetype_config) do
    if cfg.lsp and not cfg.lsp.filetypes then
        cfg.lsp.filetypes = {ft}
    end
end

local mason_tools = {}
for _, cfg in pairs(filetype_config) do
    if cfg.lsp then
        table.insert(mason_tools, cfg.lsp.server)
    end
    if cfg.formatter then
        for _, f in ipairs(cfg.formatter) do
            table.insert(mason_tools, f)
        end
    end
end

local function unique(tbl)
    local seen = {}
    local res = {}
    for _, v in ipairs(tbl) do
        if not seen[v] then
            table.insert(res, v)
            seen[v] = true
        end
    end
    return res
end

mason_tools = unique(mason_tools)

vim.schedule(function()
    local registry = require("mason-registry")
    local to_install = {}

    for _, tool in ipairs(mason_tools) do
        local ok, pkg = pcall(registry.get_package, tool)
        if ok and pkg and not pkg:is_installed() then
            table.insert(to_install, tool)
        end
    end

    if #to_install > 0 then
        vim.notify("Installing missing Mason tools: " .. table.concat(to_install, " "), vim.log.levels.INFO)
        vim.cmd("MasonInstall " .. table.concat(to_install, " "))
    end
end)

local common_config = {
    capabilities = {
        textDocument = {
            semanticTokens = {
                multilineTokenSupport = true
            }
        }
    },
    root_markers = {".git"}
}

vim.lsp.config("*", common_config)

for _, cfg in pairs(filetype_config) do
    if cfg.lsp then
        vim.lsp.config[cfg.lsp.server] = cfg.lsp
        vim.lsp.enable({cfg.lsp.server})
    end
end

for ft, cfg in pairs(filetype_config) do
    if cfg.formatter then
        require("conform").formatters_by_ft[ft] = cfg.formatter
    end
end
