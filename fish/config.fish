# Disable the default Fish greeting message
set -U fish_greeting ""

# Check if Homebrew is installed, and if so, initialize its environment
if test -x /opt/homebrew/bin/brew
    eval (/opt/homebrew/bin/brew shellenv)
end

# Add Go binaries to PATH if Go is installed
if command -q go
    # Use `go env GOPATH` to get the GOPATH and add its bin directory to PATH
    fish_add_path (go env GOPATH)/bin
end

# Define an alias 'ip' to display IPv4 address information
# Uses ifconfig to get network interface details, and awk to filter for IPv4 addresses and interface names
alias ip="ifconfig | awk '/inet / && !/inet6/ {print \$2, \$1}'"

# Define an alias 'h' for quickly navigating to the user's home directory
alias h="cd \"$HOME\""

# Define a function 'now' to display the current date and time and Unix timestamp
function now
    echo -n "Current Date and Time: "
    date '+%Y-%m-%dT%H:%M:%S%z'
    echo -n "Unix Timestamp: "
    date +%s
end

# Define a function 'timestamp' to display the current Unix timestamp
function timestamp
    date +%s
end

# Define a function 'format_timestamp' to format a given Unix timestamp into a human-readable date and time
# Usage: format_timestamp <timestamp>
function format_timestamp
    date -r $argv[1] "+%Y-%m-%d %H:%M:%S"
end

if status is-interactive
    # Commands to run in interactive sessions can go here
end
