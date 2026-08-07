-- https://github.com/nvim-treesitter/nvim-treesitter
return {
	"nvim-treesitter/nvim-treesitter",
	build = ":TSUpdate",
	config = function()
		local treesitter = require("nvim-treesitter")
		local installing = {}
		local ignored_filetypes = {
			["neo-tree"] = true,
			["neo-tree-popup"] = true,
			["neo-tree-preview"] = true,
			help = true,
			lazy = true,
			mason = true,
			checkhealth = true,
		}

		local function parser_installed(language)
			return #vim.api.nvim_get_runtime_file("parser/" .. language .. ".*", false) > 0
		end

		local function enable(bufnr, winid, language)
			if not vim.api.nvim_buf_is_valid(bufnr) or not parser_installed(language) then
				return
			end

			pcall(vim.treesitter.start, bufnr, language)
			if vim.api.nvim_win_is_valid(winid) and vim.api.nvim_win_get_buf(winid) == bufnr then
				if not vim.wo[winid].foldexpr:find("lsp", 1, true) then
					vim.wo[winid].foldmethod = "expr"
					vim.wo[winid].foldexpr = "v:lua.vim.treesitter.foldexpr()"
				end
			end
		end

		local function install_and_enable(bufnr, winid, language)
			if installing[language] then
				return
			end

			installing[language] = true
			treesitter.install({ language }, { summary = false }):await(function(err)
				installing[language] = nil
				if err then
					vim.schedule(function()
						vim.notify(("Failed to install Treesitter parser %s: %s"):format(language, err), vim.log.levels.WARN)
					end)
					return
				end
				vim.schedule(function()
					enable(bufnr, winid, language)
				end)
			end)
		end

		local available = {}
		for _, language in ipairs(treesitter.get_available()) do
			available[language] = true
		end

		vim.api.nvim_create_autocmd("FileType", {
			group = vim.api.nvim_create_augroup("treesitter_features", { clear = true }),
			desc = "Install parsers and enable Treesitter features",
			callback = function(event)
				if ignored_filetypes[event.match] or vim.bo[event.buf].buftype ~= "" then
					return
				end

				local language = vim.treesitter.language.get_lang(event.match) or event.match
				if not available[language] then
					return
				end

				local winid = vim.api.nvim_get_current_win()
				if parser_installed(language) then
					enable(event.buf, winid, language)
				else
					install_and_enable(event.buf, winid, language)
				end
			end,
		})

		local essentials = { "lua", "vim", "vimdoc", "query" }
		local missing = vim.tbl_filter(function(language)
			return not parser_installed(language)
		end, essentials)
		if #missing > 0 then
			treesitter.install(missing, { summary = false })
		end
	end,
}
