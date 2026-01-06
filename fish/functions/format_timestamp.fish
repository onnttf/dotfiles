function format_timestamp --description "Format a Unix epoch as YYYY-MM-DD HH:MM:SS"
    if test (count $argv) -ne 1
        echo "Usage: format_timestamp <timestamp>" >&2
        return 1
    end

    if not string match -qr '^[0-9]+$' -- "$argv[1]"
        echo "format_timestamp: timestamp must be numeric" >&2
        return 1
    end

    if test (uname) = Darwin
        date -r "$argv[1]" '+%Y-%m-%d %H:%M:%S'
    else
        date -d "@$argv[1]" '+%Y-%m-%d %H:%M:%S'
    end
end
