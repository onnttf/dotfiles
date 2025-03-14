-- Set the leader keys to space
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- [[ Setting options ]]
-- Define a table with common Neovim options
local options = {
    number = true,               -- Enable line numbers
    mouse = "a",                 -- Enable mouse support in all modes
    showmode = false,            -- Disable showing the mode (e.g., -- INSERT --)
    breakindent = true,          -- Enable break indent
    ignorecase = true,           -- Case insensitive searching by default
    smartcase = true,            -- Override ignorecase if search pattern contains uppercase letters
    signcolumn = "yes",          -- Always show the sign column
    updatetime = 250,            -- Faster completion (reduced update time)
    timeoutlen = 300,            -- Time (in ms) to wait for a mapped sequence to complete
    splitright = true,           -- Vertical splits open to the right
    splitbelow = true,           -- Horizontal splits open below
    list = true,                 -- Enable displaying whitespace characters
    listchars = {                -- Define symbols for displaying whitespace
        tab = "» ",              -- Represent tabs as "» " 
        trail = "·",             -- Represent trailing spaces as "·"
        nbsp = "␣"               -- Represent non-breakable spaces as "␣"
    },
    cursorline = true,           -- Highlight the current line
    scrolloff = 10,              -- Keep 10 lines visible above and below the cursor
    undofile = true              -- Enable persistent undo
}

-- Loop through the options table and apply each setting
for k, v in pairs(options) do
    vim.opt[k] = v
end

-- Schedule clipboard option to be set after startup
vim.schedule(function()
    vim.opt.clipboard = "unnamedplus"  -- Use the system clipboard for all yank, delete, change and put operations
end)

-- [[ Basic Keymaps ]]
-- Define default options for key mappings: non-recursive and silent
local default_opts = {
    noremap = true,
    silent = true
}

-- Helper function to create key mappings with default options merged
local function keymap(mode, lhs, rhs, opts)
    opts = opts or {}
    opts = vim.tbl_extend("force", default_opts, opts)
    vim.keymap.set(mode, lhs, rhs, opts)
end

-- Map <Esc> in normal mode to clear search highlights and reset the search register
keymap("n", "<Esc>", "<cmd>nohlsearch<CR><cmd>let @/ = ''<CR>", {
    desc = "Clear search highlights and reset search register"
})

-- Window navigation key mappings in normal mode
keymap("n", "<C-h>", "<C-w>h", {
    desc = "Move focus to the left window"
})
keymap("n", "<C-j>", "<C-w>j", {
    desc = "Move focus to the lower window"
})
keymap("n", "<C-k>", "<C-w>k", {
    desc = "Move focus to the upper window"
})
keymap("n", "<C-l>", "<C-w>l", {
    desc = "Move focus to the right window"
})

-- Remap 'k' and 'j' to handle wrapped lines properly
keymap("n", "k", "v:count == 0 ? 'gk' : 'k'", {
    expr = true,    -- Evaluate the mapping as an expression
    silent = true
})
keymap("n", "j", "v:count == 0 ? 'gj' : 'j'", {
    expr = true,    -- Evaluate the mapping as an expression
    silent = true
})

-- In visual mode, remap 'p' so that pasting does not overwrite the default register
keymap("v", "p", '"_d"+p', {
    desc = "Paste from clipboard without overwriting the default register"
})

-- [[ Basic Autocommands ]]
-- Create an augroup for user-defined autocommands
local augroup = vim.api.nvim_create_augroup("UserConfig", {
    clear = true
})

-- Autocommand: Highlight yanked text momentarily after a yank operation
vim.api.nvim_create_autocmd("TextYankPost", {
    group = augroup,
    desc = "Highlight yanked text",
    callback = function()
        vim.highlight.on_yank()
    end
})

-- Autocommand: Auto-create missing directories before saving a file
vim.api.nvim_create_autocmd("BufWritePre", {
    group = augroup,
    desc = "Auto-create directories when saving a file",
    callback = function(event)
        -- Skip if the file path is a URL or remote path
        if event.match:match("^%w%w+:[\\/][\\/]") then
            return
        end
        -- Resolve the real file path
        local file = vim.uv.fs_realpath(event.match) or event.match
        -- Create the directory if it doesn't exist
        vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
    end
})

-- Autocommand: Use 'q' to close specific buffer types (help, lspinfo, neo-tree, quickfix)
vim.api.nvim_create_autocmd("FileType", {
    group = augroup,
    desc = "Use 'q' to close specific buffers",
    pattern = {"help", "lspinfo", "neo-tree", "qf"},
    callback = function(event)
        vim.bo[event.buf].buflisted = false  -- Exclude buffer from the buffer list
        vim.keymap.set("n", "q", "<cmd>close<CR>", {
            buffer = event.buf,
            silent = true
        })
    end
})

-- Autocommand: Return the cursor to the last known position when reopening a file
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

-- Autocommand: Automatically resize splits when the Vim window is resized
vim.api.nvim_create_autocmd("VimResized", {
    group = augroup,
    desc = "Auto-resize splits on window resize",
    callback = function()
        vim.cmd("tabdo wincmd =")
    end
})

-- [[ Install `lazy.nvim` plugin manager ]]
-- Setup Lazy.nvim (plugin manager)
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
-- If Lazy.nvim is not installed, clone it from its GitHub repository
if not vim.uv.fs_stat(lazypath) then
    local lazyrepo = "https://github.com/folke/lazy.nvim.git"
    local out = vim.fn.system({"git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath})
    if vim.v.shell_error ~= 0 then
        error("Error cloning lazy.nvim:\n" .. out)
    end
end
-- Prepend Lazy.nvim to the runtime path
vim.opt.rtp:prepend(lazypath)

-- [[ Configure and install plugins ]]
-- Configure plugins using Lazy.nvim
require("lazy").setup({
    checker = {
        enabled = false  -- Disable automatic plugin update checks
    },
    rocks = {
        enabled = false  -- Disable integration with luarocks
    },
    spec = {
        -- {
        --     "tpope/vim-sleuth",  -- Automatically detect tabstop and shiftwidth settings
        --     opts={}
        -- },
        {
            "folke/which-key.nvim",  -- Plugin to display available key mappings in a popup
            event = "VeryLazy",
            keys = {{
                "<leader>?",
                function()
                    require("which-key").show({ global = false })
                end,
                desc = "Buffer Local Keymaps (which-key)"
            }},
            opts={
                icons = {
					mappings = false, -- Disable icons in keybindings.
				}
            }
        },
        {
            "folke/todo-comments.nvim",  -- Highlight and search for TODO and similar comments
            event = "VeryLazy",
            dependencies = {"nvim-lua/plenary.nvim"}
        },
        {
            "nvim-neo-tree/neo-tree.nvim", -- A modern file explorer for Neovim
            event = "VeryLazy",
            branch = "v3.x",
            dependencies = {
              "nvim-lua/plenary.nvim",
              "nvim-tree/nvim-web-devicons",
              "MunifTanjim/nui.nvim",
            },
            config = function()
                require("neo-tree").setup({
                    use_default_mappings = false,
                    close_if_last_window = true,
                    popup_border_style = "rounded",
                    sources = { "filesystem", "document_symbols", "buffers" },
                    source_selector = {
                        sources = {
                            {
                                source = "filesystem",
                            },
                            {
                                source = "document_symbols",
                            },
                            {
                                source = "buffers",
                            },
                        },
                    },
                    window = {
                        position = "float",
                        mappings = {
                            ["<"] = "prev_source",
                            [">"] = "next_source",
                            ["S"] = "open_split",
                            ["s"] = "open_vsplit",
                            ["R"] = "refresh",
                            ["<cr>"] = "open",
                        },
                    },
                    filesystem = {
                        follow_current_file = {
                            enabled = true,
                        },
                        filtered_items = {
                            show_hidden_count = true,
                            hide_dotfiles = true,
                            hide_gitignored = true,
                            hide_by_name = { "node_modules" },
                            always_show = { ".gitignored" },
                        },
                        window = {
                            mappings = {
                                ["h"] = function(state)
                                    local node = state.tree:get_node()
                                    if node.type == "directory" and node:is_expanded() then
                                        require("neo-tree.sources.filesystem").toggle_directory(state, node)
                                    else
                                        require("neo-tree.ui.renderer").focus_node(state, node:get_parent_id())
                                    end
                                end,
                                ["l"] = function(state)
                                    local node = state.tree:get_node()
                                    if node.type == "directory" then
                                        if not node:is_expanded() then
                                            require("neo-tree.sources.filesystem").toggle_directory(state, node)
                                        elseif node:has_children() then
                                            require("neo-tree.ui.renderer").focus_node(state, node:get_child_ids()[1])
                                        end
                                    end
                                end,
                                ["<tab>"] = function(state)
                                    local node = state.tree:get_node()
                                    if require("neo-tree.utils").is_expandable(node) then
                                        state.commands["toggle_node"](state)
                                    else
                                        state.commands["open"](state)
                                        vim.cmd("Neotree reveal")
                                    end
                                end,
                                ["a"] = {
                                    "add",
                                    config = {
                                        show_path = "relative",
                                    },
                                },
                                ["d"] = "delete",
                                ["r"] = "rename",
                                ["c"] = {
                                    "copy",
                                    config = {
                                        show_path = "relative",
                                    },
                                },
                                ["m"] = {
                                    "move",
                                    config = {
                                        show_path = "relative",
                                    },
                                },
                                ["H"] = "toggle_hidden",
                                ["<bs>"] = "navigate_up",
                                ["."] = "set_root",
                                ["i"] = "show_file_details",
                            },
                            fuzzy_finder_mappings = {
                                ["<down>"] = "move_cursor_down",
                                ["<C-n>"] = "move_cursor_down",
                                ["<up>"] = "move_cursor_up",
                                ["<C-p>"] = "move_cursor_up",
                            },
                        },
                    },
                    document_symbols = {
                        follow_cursor = true,
                    },
                    buffers = {
                        follow_current_file = {
                            enabled = true,
                        },
                        window = {
                            mappings = {
                                ["d"] = "buffer_delete",
                            },
                        },
                    },
                    event_handlers = {
                        {
                          event = "file_open_requested",
                          handler = function()
                            require("neo-tree.command").execute({ action = "close" })
                          end
                        },
                        {
                            event = "file_renamed",
                            handler = function(args)
                                print(args.source, " renamed to ", args.destination)
                            end
                        },
                        {
                            event = "file_moved",
                            handler = function(args)
                                print(args.source, " moved to ", args.destination)
                            end
                        }
                      }
                })
            end
        },
        {
            'MeanderingProgrammer/render-markdown.nvim',  -- Render Markdown files within Neovim
            ft = {"markdown"},
            dependencies = {'nvim-treesitter/nvim-treesitter'}
        },
        {
            "ibhagwan/fzf-lua",  -- Fuzzy finder implemented in Lua
            event = "VeryLazy"
        },
        {
            "lukas-reineke/indent-blankline.nvim",  -- Show indentation guides
            event = "VeryLazy",
            main = "ibl"
        },
        {
            "nvim-treesitter/nvim-treesitter",  -- Treesitter for advanced syntax highlighting and indentation
            event = "VeryLazy",
            build = ":TSUpdate",
            config = function()
                local configs = require("nvim-treesitter.configs")
                configs.setup({
                    auto_install = true,   -- Automatically install missing language parsers
                    highlight = {
                        enable = true    -- Enable treesitter-based syntax highlighting
                    },
                    indent = {
                        enable = true    -- Enable treesitter-based indentation
                    }
                })
            end
        },
        {
            "folke/trouble.nvim",  -- UI for showing diagnostics, quickfix, and location lists
            cmd = { "Trouble" },
			opts = {},
			keys = {
				{
				  "<leader>sd",
				  "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
				  desc = "[S]how [D]iagnostics"
				},
				{
				  "<leader>ss",
				  "<cmd>Trouble symbols toggle focus=false<cr>",
				  desc = "[S]how [S]ymbols",
				}
			  },
        },
        {
            "stevearc/conform.nvim",  -- Code formatting plugin
            event = {"BufWritePre"},
            cmd = {"ConformInfo"},
            keys = {{
                "<leader>f",
                function()
                    require("conform").format({ async = true })
                end,
                mode = "",
                desc = "Format buffer"
            }},
            opts = {
                format_on_save = function(bufnr)
                    -- Skip formatting if autoformat is disabled globally or for the buffer
                    if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
                        return
                    end
                    local bufname = vim.api.nvim_buf_get_name(bufnr)
                    if bufname:match("/node_modules/") then
                        return
                    end
                    return {
                        timeout_ms = 500,
                        lsp_format = "fallback"  -- Use LSP formatting as a fallback
                    }
                end
            },
            init = function()
                vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
            end
        },
        {
            'echasnovski/mini.ai',  -- Enhanced text objects for better selections
            event = "VeryLazy",
            version = '*',
            opts = {}
        },
        {
            'echasnovski/mini.surround',  -- Plugin to easily manipulate surrounding characters
            event = "VeryLazy",
            version = '*',
            opts = {}
        },
        {
            'echasnovski/mini.statusline',  -- Lightweight and minimal status line
            event = "VeryLazy",
            version = '*',
            config = function()
                local statusline = require("mini.statusline")
				statusline.setup()
				statusline.section_location = function()
					return "%2l:%-2v" -- Show line and column numbers.
				end
            end
        },
        {
            'echasnovski/mini.pairs',  -- Auto-close pairs such as brackets and quotes
            event = "VeryLazy",
            version = '*',
            opts = {}
        },
        {
            "neovim/nvim-lspconfig",  -- Configurations for Neovim's built-in LSP client
            dependencies = {{
                "WhoIsSethDaniel/mason-tool-installer.nvim",  -- Automatically install LSP, linters, and formatters
                config = function()
                    local filetype_config = require("filetype_config")
                    local tool_set = {
                        codespell = true
                    }
                    for _, config in pairs(filetype_config) do
                        for _, tools in ipairs({config.lsp, config.formatter, config.linter}) do
                            if tools then
                                for tool, _ in pairs(tools) do
                                    tool_set[tool] = true
                                end
                            end
                        end
                    end
                    local ensure_installed = vim.tbl_keys(tool_set)
                    require("mason-tool-installer").setup({
                        ensure_installed = ensure_installed
                    })
                end
            }, {
                "williamboman/mason.nvim",  -- Package manager for LSP servers, DAP, linters, etc.
                config = function()
                    require("mason").setup()
                end
            }, {
                "williamboman/mason-lspconfig.nvim",  -- Integrates Mason with LSP configurations
                config = function()
                    local lspconfig = require("lspconfig")
                    local filetype_config = require("filetype_config")
                    local capabilities = require("blink.cmp").get_lsp_capabilities()
                    require("mason-lspconfig").setup({
                        handlers = {function(server_name)
                            local server_config = {}
                            for _, config in pairs(filetype_config) do
                                if config.lsp and config.lsp[server_name] then
                                    server_config = config.lsp[server_name] or {}
                                    break
                                end
                            end
                            server_config.capabilities = vim.tbl_deep_extend("force", {}, capabilities,
                                server_config.capabilities or {})
                            lspconfig[server_name].setup(server_config)
                        end}
                    })
                end
            }},
            config = function()
                -- Set up key mappings when an LSP server attaches to a buffer
                vim.api.nvim_create_autocmd("LspAttach", {
                    group = augroup,
                    callback = function(ev)
                        -- Enable LSP-based omnifunc completion
                        vim.bo[ev.buf].omnifunc = "v:lua.vim.lsp.omnifunc"
                        local localOpts = { buffer = ev.buf }
                        keymap("n", "gd", vim.lsp.buf.definition, vim.tbl_extend("force", localOpts, {
                            desc = "Go to definition"
                        }))
                        keymap("n", "gD", vim.lsp.buf.declaration, vim.tbl_extend("force", localOpts, {
                            desc = "Go to declaration"
                        }))
                        keymap("n", "gr", vim.lsp.buf.references, vim.tbl_extend("force", localOpts, {
                            desc = "Go to references"
                        }))
                        keymap("n", "gi", vim.lsp.buf.implementation, vim.tbl_extend("force", localOpts, {
                            desc = "Go to implementation"
                        }))
                        keymap("n", "gt", vim.lsp.buf.type_definition, vim.tbl_extend("force", localOpts, {
                            desc = "Go to type definition"
                        }))
                        keymap("n", "K", vim.lsp.buf.hover, vim.tbl_extend("force", localOpts, {
                            desc = "Show hover information"
                        }))
                        keymap("n", "<C-k>", vim.lsp.buf.signature_help, vim.tbl_extend("force", localOpts, {
                            desc = "Show signature help"
                        }))
                        keymap("n", "er", vim.lsp.buf.rename, vim.tbl_extend("force", localOpts, {
                            desc = "Rename symbol"
                        }))
                        keymap({"n", "v"}, "ea", vim.lsp.buf.code_action, vim.tbl_extend("force", localOpts, {
                            desc = "Code actions"
                        }))
                    end
                })
            end
        },
        {
            "saghen/blink.cmp",  -- Autocompletion engine
            event = "VeryLazy",
            version = "*",
            dependencies = "rafamadriz/friendly-snippets",
            opts = {
                keymap = {
                    ["<CR>"] = {"accept", "fallback"},
                    ["<Tab>"] = {"select_next", "snippet_forward", "fallback"},
                    ["<S-Tab>"] = {"select_prev", "snippet_backward", "fallback"},
                    ["<Up>"] = {"select_prev", "fallback"},
                    ["<Down>"] = {"select_next", "fallback"},
                    ["<C-b>"] = {"scroll_documentation_up", "fallback"},
                    ["<C-f>"] = {"scroll_documentation_down", "fallback"}
                },
                cmdline = {
                    enabled = false
                },
                completion = {
                    accept = {
                        auto_brackets = {
                            enabled = false
                        }
                    },
                    list = {
                        selection = {
                            preselect = false,
                            auto_insert = true
                        }
                    },
                    documentation = {
                        auto_show = true,
                        auto_show_delay_ms = 500
                    },
                    ghost_text = {
                        enabled = true
                    }
                },
                sources = {
                    default = {"lsp", "path", "snippets", "buffer"}
                },
                signature = {
                    enabled = true
                }
            }
        },
        {
            "mfussenegger/nvim-dap",  -- Debug Adapter Protocol integration for debugging
            event = "VeryLazy",
            dependencies = {{
                "rcarriga/nvim-dap-ui",  -- UI for nvim-dap
                dependencies = {"nvim-neotest/nvim-nio"}
            }, {"theHamsta/nvim-dap-virtual-text"}},  -- Show virtual text for DAP
            config = function()
                local dap, dapui = require("dap"), require("dapui")
                dap.listeners.before.attach.dapui_config = function()
                    dapui.open()  -- Open the DAP UI when attaching the debugger
                end
                dap.listeners.before.launch.dapui_config = function()
                    dapui.open()  -- Open the DAP UI before launching a debug session
                end
                dap.listeners.before.event_terminated.dapui_config = function()
                    dapui.close()  -- Close the DAP UI when debugging is terminated
                end
                dap.listeners.before.event_exited.dapui_config = function()
                    dapui.close()  -- Close the DAP UI when the debug session exits
                end
            end
        },
        {
            "leoluz/nvim-dap-go",  -- DAP configuration specifically for Go
            ft = "go",
            config = function()
                require("dap-go").setup({
                    delve = {
                        path = "/Users/zhangpeng/go/bin/dlv"  -- Specify the path to the Delve debugger executable
                    }
                })
            end
        }
    }
})
