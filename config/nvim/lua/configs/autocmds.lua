local utils = require("utils.utils") -- Load 'utils' module here

local augroup = function(name)
    return vim.api.nvim_create_augroup("AutoGroup_" .. name, {
        clear = true
    })
end

local autocmd = vim.api.nvim_create_autocmd

-- Check if we need to reload the file when it changes
autocmd({ "FocusGained", "TermClose", "TermLeave" },
    {
        group = augroup("checktime"),
        command = "checktime"
    }
)

-- Highlight on yank
autocmd("TextYankPost",
    {
        group = augroup("text_yank_post"),
        callback = vim.highlight.on_yank
    }
)

-- Resize splits if the window is resized
autocmd("VimResized",
    {
        group = augroup("vim_resized"),
        callback = function()
            vim.cmd("tabdo wincmd =")
        end
    }
)

-- Go to last location when opening a buffer
autocmd("BufReadPost",
    {
        group = augroup("buf_read_post"),
        callback = function()
            local mark = vim.api.nvim_buf_get_mark(0, '"')
            local lcount = vim.api.nvim_buf_line_count(0)
            if mark[1] > 0 and mark[1] <= lcount then
                pcall(vim.api.nvim_win_set_cursor, 0, mark)
            end
        end
    }
)

-- Close some filetypes with <q>
autocmd("FileType",
    {
        group = augroup("close"),
        pattern = { "PlenaryTestPopup", "help", "lspinfo", "man", "notify", "qf", "spectre_panel", "startuptime",
            "tsplayground", "checkhealth" },
        callback = function(event)
            vim.bo[event.buf].buflisted = false
            utils.keymap("n", "q", "<cmd>close<cr>", {
                desc = "Close file."
            })
        end
    }
)

-- Auto create directory when saving a file, in case some intermediate directory does not exist
autocmd("BufWritePre",
    {
        group = augroup("buf_write_pre"),
        callback = function(event)
            if event.match:match("^%w%w+://") then
                return
            end
            local file = vim.loop.fs_realpath(event.match) or event.match
            vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
        end
    }
)
