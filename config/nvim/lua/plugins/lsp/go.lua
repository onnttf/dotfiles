-- https://github.com/ray-x/go.nvim
require("go").setup({
	-- Specify the tag transform option ('snakecase', 'camelcase', etc.)
	-- Check 'gomodifytags' for details and additional options
	tag_transform = "camelcase",
})

-- Automatically run gofmt + goimport on save
-- local format_sync_grp = vim.api.nvim_create_augroup("GoImport", {})
-- vim.api.nvim_create_autocmd("BufWritePre", {
--     pattern = "*.go",
--     callback = function()
--         require('go.format').goimport()
--     end,
--     group = format_sync_grp
-- })
