-- https://github.com/leoluz/nvim-dap-go
return {
	"leoluz/nvim-dap-go",
	dependencies = { "mfussenegger/nvim-dap" },
	ft = "go",
	config = function()
		require("dap-go").setup()
	end,
}
