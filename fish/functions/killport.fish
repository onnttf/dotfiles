function killport --description "Signal processes listening on a TCP port"
    if test (count $argv) -lt 1; or test (count $argv) -gt 2
        echo "Usage: killport <port> [signal]" >&2
        return 1
    end

    require_command lsof; or return

    set -l port "$argv[1]"
    set -l signal TERM

    if test (count $argv) -eq 2
        set signal "$argv[2]"
    end

    if not string match -qr '^[0-9]+$' -- "$port"
        echo "killport: port must be numeric" >&2
        return 1
    end

    set -l pids (lsof -tiTCP:"$port" -sTCP:LISTEN)

    if test (count $pids) -eq 0
        echo "killport: no process is listening on port $port" >&2
        return 1
    end

    kill -s "$signal" $pids
end
