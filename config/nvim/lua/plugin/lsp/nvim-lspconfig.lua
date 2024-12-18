-- Import required modules
local lspconfig = require("lspconfig")
local filetype_config = require("plugin.lsp.filetype_config")

-- Set up mason
require("mason").setup()

-- Configure LSP capabilities
local capabilities = require("blink.cmp").get_lsp_capabilities()

-- Collect tools to be installed
local tool_set = {
	codespell = true,
}

for _, config in pairs(filetype_config) do
	for _, tools in ipairs({ config.lsp, config.formatter, config.linter }) do
		if tools then
			for tool, _ in pairs(tools) do
				tool_set[tool] = true
			end
		end
	end
end

-- Prepare list of tools for installation
local ensure_installed = vim.tbl_keys(tool_set)

-- Set up mason-tool-installer
require("mason-tool-installer").setup({ ensure_installed = ensure_installed })

-- Set up mason-lspconfig
require("mason-lspconfig").setup({
	handlers = {
		function(server_name)
			local server_config = {}
			for _, config in pairs(filetype_config) do
				if config.lsp and config.lsp[server_name] then
					server_config = config.lsp[server_name] or {}
					break
				end
			end
			server_config.capabilities =
				vim.tbl_deep_extend("force", {}, capabilities, server_config.capabilities or {})
			lspconfig[server_name].setup(server_config)
		end,
	},
})
