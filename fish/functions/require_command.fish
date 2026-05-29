function require_command --description "Require an executable command"
    if test (count $argv) -ne 1
        echo "Usage: require_command <command>" >&2
        return 2
    end

    if not command -q "$argv[1]"
        echo "$argv[1]: command not found" >&2
        return 127
    end
end
