# Disable Fish greeting message on startup
set -g fish_greeting

# Alias
# Show local IP (excluding IPv6)
alias ip="ifconfig | awk '/inet / && !/inet6/ {print \$1, \$2}'"
# Quickly navigate to home directory
alias h="cd \"$HOME\""

# Function to display current date/time in RFC 3339 format and Unix timestamp
function now
    echo -n "Current Date and Time: "
    # RFC 3339 format (with timezone)
    date '+%Y-%m-%dT%H:%M:%S%z'
    
    echo -n "Unix Timestamp: "
    # Unix timestamp (seconds since epoch)
    date +%s
end

# Function to return the current Unix timestamp
function timestamp
    date +%s  # Unix timestamp (seconds since epoch)
end

# Function to format Unix timestamp into human-readable date
function format_timestamp
    # Convert timestamp to YYYY-MM-DD HH:MM:SS
    date -r $argv[1] "+%Y-%m-%d %H:%M:%S"
end

# Conditional block for commands that run only in interactive sessions
if status is-interactive
    # Commands for interactive mode go here
end

# Initialize Homebrew environment (ensure proper setup for Homebrew)
if test -x /opt/homebrew/bin/brew
    eval "$(/opt/homebrew/bin/brew shellenv)"
end
