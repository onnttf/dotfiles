# Disable the default Fish greeting message
set -U fish_greeting ""

# Add Go binaries to PATH if Go is installed
if command -q go
    fish_add_path $HOME/go/bin
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

# Remove .DS_Store files
function rmds
    bash -c "$(curl -fsSL https://gist.githubusercontent.com/onnttf/10e50e0b4f03dd06e584453dac1ca53e/raw/remove-ds-store.sh)"
end

# Create directory and cd into it
function mkcd
    mkdir -p $argv[1]; and cd $argv[1]
end

# Extract various archive formats
function extract
    if test (count $argv) -eq 0
        echo "Usage: extract <file>"
        return 1
    end
    if test -f $argv[1]
        switch $argv[1]
            case "*.tar.bz2"
                tar xjf $argv[1]
            case "*.tar.gz" "*.tgz"
                tar xzf $argv[1]
            case "*.bz2"
                bunzip2 $argv[1]
            case "*.rar"
                unrar x $argv[1]
            case "*.gz"
                gunzip $argv[1]
            case "*.tar"
                tar xf $argv[1]
            case "*.tbz2"
                tar xjf $argv[1]
            case "*.xz"
                xz -d $argv[1]
            case "*.zip"
                unzip $argv[1]
            case "*.7z"
                7z x $argv[1]
            case "*"
                echo "extract: unknown archive format"
                return 1
        end
    else
        echo "extract: $argv[1]: not a file"
        return 1
    end
end

# Show processes listening on ports
function ports
    lsof -i -P -n | grep LISTEN
end

# Kill process on specified port
function killport
    if test (count $argv) -eq 0
        echo "Usage: killport <port>"
        return 1
    end
    lsof -ti:$argv[1] | xargs kill -9
end

# Show SSH public key
function pubkey
    cat ~/.ssh/id_ed25519.pub 2>/dev/null; or cat ~/.ssh/id_rsa.pub 2>/dev/null
end

if status is-interactive
    # Commands to run in interactive sessions can go here
end
