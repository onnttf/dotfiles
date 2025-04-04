-- [[ Option ]]
local options = {
    number = true, -- Enable line numbers
    mouse = "a", -- Enable mouse support in all modes
    showmode = false, -- Disable showing the mode (e.g., -- INSERT --)
    breakindent = true, -- Enable break indent
    ignorecase = true, -- Case insensitive searching by default
    smartcase = true, -- Override ignorecase if search pattern contains uppercase letters
    signcolumn = "yes", -- Always show the sign column
    updatetime = 250, -- Faster completion (reduced update time)
    timeoutlen = 300, -- Time (in ms) to wait for a mapped sequence to complete
    splitright = true, -- Vertical splits open to the right
    splitbelow = true, -- Horizontal splits open below
    list = true, -- Enable displaying whitespace characters
    listchars = { -- Define symbols for displaying whitespace
        tab = "» ", -- Represent tabs as "» "
        trail = "·", -- Represent trailing spaces as "·"
        nbsp = "␣" -- Represent non-breakable spaces as "␣"
    },
    cursorline = true, -- Highlight the current line
    scrolloff = 10, -- Keep 10 lines visible above and below the cursor
    clipboard = "unnamedplus" -- Use the system clipboard for all yank, delete, change and put operations
}

-- Apply the options
for k, v in pairs(options) do
    vim.opt[k] = v
end
