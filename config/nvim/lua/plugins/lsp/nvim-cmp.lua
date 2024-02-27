-- https://github.com/hrsh7th/nvim-cmp

local vim = vim
local cmp = require("cmp")

-- Function to feed key input
local feedkey = function(key, mode)
	vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(key, true, true, true), mode, true)
end

-- Function to check if there are words before the cursor
local has_words_before = function()
	local line, col = unpack(vim.api.nvim_win_get_cursor(0))
	return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

-- Icons for different kinds of completion items
local kind_icons = {
	Text = "",
	Method = "󰆧",
	Function = "󰊕",
}

-- cmp setup
cmp.setup({
	enabled = function()
		local context = require("cmp.config.context")

		-- Enable cmp in command-line mode and not in treesitter comments or syntax group comments
		if vim.api.nvim_get_mode().mode == "c" then
			return true
		else
			return not context.in_treesitter_capture("comment") and not context.in_syntax_group("Comment")
		end
	end,
	formatting = {
		format = function(entry, vim_item)
			-- Customize the display format for completion items
			vim_item.kind = string.format("%s %s", kind_icons[vim_item.kind], vim_item.kind)

			vim_item.menu = ({
				buffer = "[Buffer]",
				nvim_lsp = "[LSP]",
				luasnip = "[LuaSnip]",
				nvim_lua = "[Lua]",
				latex_symbols = "[LaTeX]",
			})[entry.source.name]
			return vim_item
		end,
	},
	preselect = cmp.PreselectMode.None,
	snippet = {
		expand = function(args)
			vim.fn["vsnip#anonymous"](args.body)
		end,
	},
	mapping = {
		["<Tab>"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_next_item()
			elseif vim.fn["vsnip#available"](1) == 1 then
				feedkey("<Plug>(vsnip-expand-or-jump)", "")
			elseif has_words_before() then
				cmp.complete()
			else
				fallback()
			end
		end, { "i", "s" }),
		["<S-Tab>"] = cmp.mapping(function()
			if cmp.visible() then
				cmp.select_prev_item()
			elseif vim.fn["vsnip#jumpable"](-1) == 1 then
				feedkey("<Plug>(vsnip-jump-prev)", "")
			end
		end, { "i", "s" }),
		["<CR>"] = cmp.mapping({
			i = function(fallback)
				if cmp.visible() and cmp.get_active_entry() then
					cmp.confirm({
						behavior = cmp.ConfirmBehavior.Replace,
						select = false,
					})
				else
					fallback()
				end
			end,
			s = cmp.mapping.confirm({
				select = true,
			}),
			c = cmp.mapping.confirm({
				behavior = cmp.ConfirmBehavior.Replace,
				select = true,
			}),
		}),
	},
	sources = cmp.config.sources({
		{
			name = "nvim_lsp",
		},
		{
			name = "vsnip",
		},
		{
			name = "buffer",
		},
		{
			name = "path",
		},
	}),
})

-- cmp setup for cmdline mode with specific sources
cmp.setup.cmdline("/", {
	mapping = cmp.mapping.preset.cmdline(),
	completion = {
		autocomplete = false,
	},
	sources = {
		{
			name = "buffer",
		},
	},
})

cmp.setup.cmdline(":", {
	mapping = cmp.mapping.preset.cmdline(),
	completion = {
		autocomplete = false,
	},
	enabled = function()
		-- Disable cmp for specific cmdline modes
		local disabled = {
			IncRename = true,
			s = true,
			sm = true,
		}
		local cmd = vim.fn.getcmdline():match("%S+")
		return not disabled[cmd] or cmp.close()
	end,
	sources = cmp.config.sources({
		{
			name = "path",
		},
	}, {
		{
			name = "cmdline",
		},
	}),
})
