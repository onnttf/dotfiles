# Disable the fish greeting message
set -g fish_greeting

# Initialize interactive session settings
if status is-interactive
    # Configure default editor if neovim is available
    if command -sq nvim
        set -gx EDITOR nvim
    end
end

# Setup Go development environment
if command -v go >/dev/null
    set -gx GOPATH (go env GOPATH)
    set -gx GOROOT (go env GOROOT)

    for path in $GOPATH/bin $GOROOT/bin
        if test -d $path; and not contains $path $PATH
            fish_add_path $path
        end
    end
end

# Common aliases for frequently used commands
alias n="nvim"
alias ip="ifconfig | awk '/inet / && !/inet6/ {print \$1, \$2}'"
alias h="cd $HOME"

# Utility Functions

# Create and navigate to directory
function mkcd
    if test (count $argv) -eq 0
        echo "Usage: mkcd <dir1> [dir2 ...]"
        return 1
    end
    mkdir -p $argv[-1] && cd $argv[-1]
end

# Enhanced process search
function psearch
    test (count $argv) -eq 0; and echo "Usage: psearch <process-name>" and return 1
    echo "USER        PID  %CPU %MEM      VSZ    RSS TTY      STAT STARTED                      ELAPSED COMMAND"
    pgrep -af $argv[1] | while read -l line
        ps -o user,pid,%cpu,%mem,vsz,rss,tty,stat,lstart,etime,command -p (echo $line | awk '{print $1}') | sed 1d
    end
end

# Quick file search
function ff
    if test (count $argv) -eq 0
        echo "Usage: ff <filename> [find options]"
        return 1
    end
    set -l name "*$argv[1]*"
    find . -type f -iname $name $argv[2..-1]
end

# Quick directory search
function fd
    if test (count $argv) -eq 0
        echo "Usage: fd <dirname> [find options]"
        return 1
    end
    set -l name "*$argv[1]*"
    find . -type d -iname $name $argv[2..-1]
end

# File backup with timestamp
function backup
    if test (count $argv) -eq 0
        echo "Usage: backup <file1> [file2 ...]"
        return 1
    end
    for file in $argv
        if test -e $file
            set -l timestamp (date +"%Y%m%d_%H%M%S")
            set -l backup_file "$file.$timestamp.bak"
            if cp -i $file $backup_file
                echo "Backup created: $backup_file"
            else
                echo "Failed to create backup for: $file"
            end
        else
            echo "File not found: $file"
        end
    end
end

# Universal archive extractor
function extract
    if test (count $argv) -eq 0
        echo "Usage: extract <file>"
        return 1
    end
    switch $argv[1]
        case '*.tar.bz2'
            tar xjf $argv[1]
        case '*.tar.gz'
            tar xzf $argv[1]
        case '*.bz2'
            bunzip2 $argv[1]
        case '*.rar'
            unrar x $argv[1]
        case '*.gz'
            gunzip $argv[1]
        case '*.tar'
            tar xf $argv[1]
        case '*.tbz2'
            tar xjf $argv[1]
        case '*.tgz'
            tar xzf $argv[1]
        case '*.zip'
            unzip $argv[1]
        case '*.Z'
            uncompress $argv[1]
        case '*.7z'
            7z x $argv[1]
        case '*'
            echo "'$argv[1]' cannot be extracted via extract()"
    end
end
