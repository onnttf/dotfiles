-- https://github.com/mfussenegger/nvim-dap
return {
	"mfussenegger/nvim-dap",
	cmd = {
		"DapContinue", "DapToggleBreakpoint", "DapStepOver",
		"DapStepInto", "DapStepOut", "DapTerminate",
	},
	dependencies = {
		{ "rcarriga/nvim-dap-ui", dependencies = { "nvim-neotest/nvim-nio" } },
		{ "theHamsta/nvim-dap-virtual-text" },
	},
	config = function()
		local dap   = require("dap")
		local dapui = require("dapui")
		dapui.setup()
		-- Auto-open dapui on debug start, close on termination.
		dap.listeners.before.attach.dapui_config = function() dapui.open() end
		dap.listeners.before.launch.dapui_config = function() dapui.open() end
		dap.listeners.before.event_terminated.dapui_config = function() dapui.close() end
		dap.listeners.before.event_exited.dapui_config   = function() dapui.close() end
		-- Show inline variable values during debugging.
		require("nvim-dap-virtual-text").setup()
	end,
}
