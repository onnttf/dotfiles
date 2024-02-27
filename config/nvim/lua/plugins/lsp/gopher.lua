-- https://github.com/olexsmir/gopher.nvim

require("gopher").setup({
	commands = {
		go = "go",
		gomodifytags = "gomodifytags",
		gotests = "~/go/bin/gotests",
		impl = "impl",
		iferr = "iferr",
	},
})
