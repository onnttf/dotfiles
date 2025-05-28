# Disable the default Fish greeting message
set -U fish_greeting ""

# Initialize Homebrew if installed
if test -x /opt/homebrew/bin/brew
    eval (/opt/homebrew/bin/brew shellenv)
end

# Add Go bin path if Go is installed
if command -q go
    fish_add_path (go env GOPATH)/bin
end

# Add MySQL 8.4 bin path if installed
if test -d /opt/homebrew/opt/mysql@8.4/bin
    fish_add_path /opt/homebrew/opt/mysql@8.4/bin
end

# Show IPv4 addresses
alias ip="ifconfig | awk '/inet / && !/inet6/ {print \$2, \$1}'"

# Go to home directory
alias h="cd \"$HOME\""

# Show current date, time, and timestamp
function now
    echo -n "Datetime: "
    date '+%Y-%m-%dT%H:%M:%S%z'
    echo -n "Timestamp: "
    date +%s
end

# Show current timestamp
function timestamp
    date +%s
end

# Format a given timestamp
# Usage: format_timestamp <timestamp>
function format_timestamp
    date -r $argv[1] "+%Y-%m-%d %H:%M:%S"
end

if status is-interactive
    # Commands to run in interactive sessions can go here
end
