require('go').setup {
    -- can be transform option("snakecase", "camelcase", etc) check gomodifytags for details and more options
    tag_transform = 'camelcase'
}

-- Run gofmt + goimport on save
-- local format_sync_grp = vim.api.nvim_create_augroup("GoImport", {})
-- vim.api.nvim_create_autocmd("BufWritePre", {
--     pattern = "*.go",
--     callback = function()
--         require('go.format').goimport()
--     end,
--     group = format_sync_grp
-- })
