-- https://github.com/Saghen/blink.cmp
return {
	"saghen/blink.cmp",
	version = "1.*",
	event = "InsertEnter",
	opts = {
		completion = {
			keyword = { range = "full" },
			accept  = { auto_brackets = { enabled = true } },
			list    = {
				max_items = 200,
				selection = { preselect = false, auto_insert = true },
			},
			menu = {
				scrolloff = 2,
				direction_priority = { "s", "n" },
				draw = {
					columns = {
						{ "label", "label_description", gap = 1 },
						{ "kind_icon", "kind" },
					},
				},
			},
			documentation = { auto_show = true, auto_show_delay_ms = 500 },
			ghost_text    = { enabled = true },
		},
		fuzzy = {
			implementation  = "prefer_rust_with_warning",
			frecency        = { enabled = true },
			use_proximity   = true,
			sorts           = { "score", "sort_text", "label" },
		},
		sources = {
			default = { "lsp", "path", "buffer" },
			providers = {
				lsp = { name = "LSP", fallbacks = {} },
				path = {
					name = "Path",
					score_offset = 3,
					opts = {
						trailing_slash = true,
						label_trailing_slash = true,
						get_cwd = function(ctx) return vim.fn.expand(("#%d:p:h"):format(ctx.bufnr)) end,
						show_hidden_files_by_default = false,
					},
				},
				buffer = {
					name = "Buffer",
					score_offset = -3,
					opts = {
						get_bufnrs = function()
							return vim.tbl_filter(function(b) return vim.bo[b].buftype == "" end, vim.api.nvim_list_bufs())
						end,
					},
				},
				cmdline = {
					min_keyword_length = function(ctx)
						if ctx.mode == "cmdline" and not ctx.line:find(" ") then return 3 end
						return 0
					end,
				},
			},
		},
		cmdline = {
			keymap = { preset = "cmdline" },
			completion = {
				menu = { auto_show = false },
				ghost_text = { enabled = true },
			},
		},
		signature  = { enabled = true },
		appearance = { nerd_font_variant = "mono" },
		keymap     = {
			preset = "none",
			["<Tab>"]   = { "select_next", "snippet_forward", "fallback" },
			["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
			["<CR>"]    = { "accept", "fallback" },
		},
	},
}
