local augroup = vim.api.nvim_create_augroup("user_config_autocommand", {
    clear = true
})

vim.api.nvim_create_autocmd("TextYankPost", {
    group = augroup,
    desc = "Highlight: Yanked text",
    callback = function()
        vim.highlight.on_yank()
    end
})

vim.api.nvim_create_autocmd("BufWritePre", {
    group = augroup,
    desc = "File: Create parent directories on save",
    callback = function(event)
        if event.match:match("^%w%w+:[\\/][\\/]") then
            return
        end
        local dir = vim.fn.fnamemodify(event.file, ":p:h")
        vim.fn.mkdir(dir, "p")
    end
})

vim.api.nvim_create_autocmd("FileType", {
    group = augroup,
    desc = "Buffer: Close utility buffers with 'q'",
    pattern = {"help", "lspinfo", "neo-tree", "qf"},
    callback = function(event)
        vim.bo[event.buf].buflisted = false
        vim.keymap.set("n", "q", "<cmd>close<CR>", {
            buffer = event.buf,
            silent = true
        })
    end
})

vim.api.nvim_create_autocmd("BufReadPost", {
    group = augroup,
    desc = "Cursor: Restore last position on buffer read",
    callback = function()
        local last_pos_mark = vim.api.nvim_buf_get_mark(0, '"')
        local lcount = vim.api.nvim_buf_line_count(0)

        if last_pos_mark[1] > 0 and last_pos_mark[1] <= lcount then
            pcall(vim.api.nvim_win_set_cursor, 0, last_pos_mark)
        end
    end
})

vim.api.nvim_create_autocmd("VimResized", {
    group = augroup,
    desc = "Window: Auto-balance splits on resize",
    callback = function()
        vim.cmd("wincmd =")
    end
})
