alias n="nvim"
alias ip="ifconfig | grep inet | grep -v inet6 | awk '{print \$1, \$2}'"
alias h="cd $HOME"
alias d="cd $HOME/Desktop"

# Check if the 'go' command exists
if command -v go >/dev/null
    # Set GOPATH and update PATH if necessary
    set -gx GOPATH (go env GOPATH)

    # Add the Go bin directory to PATH if not already present
    if not contains $GOPATH/bin $PATH
        set -gx PATH $GOPATH/bin $PATH
    end
end

# Check if the current shell is in interactive mode
if status is-interactive
    # In this branch, we handle the case when the shell is in interactive mode.
    # This section is executed when you are actively using the Fish Shell in the terminal.

    # Add commands to run in interactive sessions here.
    # For example, setting the prompt, defining aliases, and functions specifically for interactive use.
end

