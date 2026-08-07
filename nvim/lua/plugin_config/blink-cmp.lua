-- https://github.com/Saghen/blink.cmp
return {
	"saghen/blink.cmp",
	version = "1.*",
	event = "InsertEnter",
	opts = {
		keymap = {
			preset = "enter",
			["<Tab>"] = { "select_next", "snippet_forward", "fallback" },
			["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
		},
		completion = {
			keyword = { range = "full" },
			list = { selection = { preselect = false, auto_insert = true } },
			menu = {
				draw = {
					columns = {
						{ "label", "label_description", gap = 1 },
						{ "kind_icon", "kind" },
					},
				},
			},
			documentation = { auto_show = true },
			ghost_text = { enabled = true },
		},
		sources = {
			default = { "lsp", "path", "buffer" },
			providers = {
				-- Show buffer words alongside LSP results instead of only as a fallback.
				lsp = { fallbacks = {} },
				cmdline = {
					min_keyword_length = function(ctx)
						if ctx.mode == "cmdline" and not ctx.line:find(" ") then
							return 3
						end
						return 0
					end,
				},
			},
		},
		fuzzy = { sorts = { "score", "sort_text", "label" } },
		signature = { enabled = true },
	},
}
