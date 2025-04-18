local default_opts = {
	noremap = true,
	silent = true,
}

local function keymap(mode, lhs, rhs, opts)
	if not (mode and lhs and rhs) then
		vim.notify("Invalid keymap: 'mode', 'lhs', and 'rhs' are required.", vim.log.levels.ERROR)
		return
	end

	opts = vim.tbl_deep_extend("force", default_opts, opts or {})

	if not opts.desc then
		opts.desc = string.format("Keymap for %s -> %s", lhs, type(rhs) == "string" and rhs or "function")
	end

	vim.keymap.set(mode, lhs, rhs, opts)
end

return {
	keymap = keymap,
}
