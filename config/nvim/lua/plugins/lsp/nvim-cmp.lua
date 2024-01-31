-- https://github.com/hrsh7th/nvim-cmp

local vim = vim
local cmp = require("cmp")

-- Function to simulate key presses in Neovim
local feedkey = function(key, mode)
	vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(key, true, true, true), mode, true)
end

-- Function to check if there are words before the cursor
local has_words_before = function()
	local line, col = vim.fn.getpos(".")
	if col == 0 then
		return false
	end

	local current_line = vim.api.nvim_buf_get_lines(0, line[2] - 1, line[2], true)[1]
	return not current_line:sub(col, col):match("%s")
end

-- Setup nvim-cmp
cmp.setup({
	enabled = function()
		local context = require("cmp.config.context")
		-- Disable completion in comments in command mode
		if vim.api.nvim_get_mode().mode == "c" then
			return true
		else
			return not context.in_treesitter_capture("comment") and not context.in_syntax_group("Comment")
		end
	end,
	preselect = cmp.PreselectMode.None,
	matching = {
		disallow_fuzzy_matching = true,
		disallow_fullfuzzy_matching = true,
		disallow_partial_fuzzy_matching = true,
		disallow_partial_matching = true,
		disallow_prefix_unmatching = false,
	},
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
		}),
	},
	sources = cmp.config.sources({
		{ name = "nvim_lsp" },
		{ name = "vsnip" },
		{ name = "buffer" },
		{ name = "path" },
	}),
})

-- Setup cmdline completion for '/'
cmp.setup.cmdline("/", {
	mapping = cmp.mapping.preset.cmdline(),
	completion = { autocomplete = false },
	sources = { { name = "buffer" } },
})

-- Setup cmdline completion for ':'
cmp.setup.cmdline(":", {
	mapping = cmp.mapping.preset.cmdline(),
	completion = { autocomplete = false },
	enabled = function()
		local disabled = { IncRename = true, s = true, sm = true }
		local cmd = vim.fn.getcmdline():match("%S+")
		return not disabled[cmd] or cmp.close()
	end,
	sources = cmp.config.sources({ { name = "path" } }, { { name = "cmdline" } }),
})

-- Add parentheses after selecting a function or method item
local cmp_autopairs = require("nvim-autopairs.completion.cmp")
cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
