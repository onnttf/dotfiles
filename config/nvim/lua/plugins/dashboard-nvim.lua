-- https://github.com/glepnir/dashboard-nvim
require('dashboard').setup {
    config = {
        week_header = {
            enable = true
        },
        -- disable_move = true,
        shortcut = {
            {
                icon = '  ',
                desc = 'New File',
                key = 'nf',
                action = 'enew'
            },
            {
                icon = "  ",
                desc = "Find file",
                key = 'ff',
                action = ":Telescope find_files"
            },
            {
                icon = '  ',
                desc = 'Find Text',
                key = 'ft',
                action = 'Telescope live_grep'
            },
            {
                icon = '  ',
                desc = 'Config',
                key = 'c',
                action = ':e $MYVIMRC'
            },
            {
                icon = '  ',
                desc = 'Quit',
                key = 'q',
                action = 'qa'
            }
        },
        footer = { "", "🎉 Meet a better version of yourself every day." }
    }
}
