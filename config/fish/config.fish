# Aliases for convenient commands:

alias n="nvim" # 'n' as an alias for 'nvim'
alias ip="ifconfig | grep inet | grep -v inet6 | awk '{print \$1, \$2}'" # Display IPv4 addresses
alias h="cd $HOME" # Shortcut to change directory to home
alias d="cd $HOME/Desktop" # Shortcut to change directory to desktop

# Set 'neovim' as the default editor if 'neovim' is available
if command -q nvim
    set -x EDITOR nvim
end

# Set GOPATH and add GOPATH/bin to the PATH if 'go' is available
if type -q go
    set -gx GOPATH (go env GOPATH)
    fish_add_path $GOPATH/bin
end

# Check if the current shell is in interactive mode
if status is-interactive
    # This section is executed when the Fish Shell is actively used in the terminal.

    # Add commands specific to interactive sessions below.
    # Examples include setting the prompt, defining aliases, and functions for interactive use.
end
