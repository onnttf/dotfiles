-- [[ Autocommand ]]
local augroup = vim.api.nvim_create_augroup("user_config_autocommand", {
    clear = true
})

-- Highlight yanked text momentarily after a yank operation
vim.api.nvim_create_autocmd("TextYankPost", {
    group = augroup,
    desc = "Highlight yanked text",
    callback = function()
        vim.highlight.on_yank()
    end
})

-- Auto-create missing directories before saving a file
vim.api.nvim_create_autocmd("BufWritePre", {
    group = augroup,
    desc = "Auto-create directories when saving a file",
    callback = function(event)
        if event.match:match("^%w%w+:[\\/][\\/]") then
            return
        end

        local file = vim.uv.fs_realpath(event.match) or event.match
        vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
    end
})

-- Use 'q' to close specific buffer types (help, lspinfo, neo-tree, quickfix)
vim.api.nvim_create_autocmd("FileType", {
    group = augroup,
    desc = "Use 'q' to close specific buffers",
    pattern = {"help", "lspinfo", "neo-tree", "qf"},
    callback = function(event)
        vim.bo[event.buf].buflisted = false
        vim.keymap.set("n", "q", "<cmd>close<CR>", {
            buffer = event.buf,
            silent = true
        })
    end
})

-- Return the cursor to the last known position when reopening a file
vim.api.nvim_create_autocmd("BufReadPost", {
    group = augroup,
    desc = "Go to last location when reopening a file",
    callback = function()
        local mark = vim.api.nvim_buf_get_mark(0, '"')
        local lcount = vim.api.nvim_buf_line_count(0)
        if mark[1] > 0 and mark[1] <= lcount then
            pcall(vim.api.nvim_win_set_cursor, 0, mark)
        end
    end
})

-- Automatically resize splits when the Vim window is resized
vim.api.nvim_create_autocmd("VimResized", {
    group = augroup,
    desc = "Auto-resize splits on window resize",
    callback = function()
        vim.cmd("tabdo wincmd =")
    end
})
