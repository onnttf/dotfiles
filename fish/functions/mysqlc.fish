function mysqlc --description "Open mysql with password"
    if test (count $argv) -ne 5
        echo "Usage: mysqlc <host> <port> <user> <password> <database>" >&2
        return 1
    end

    if not command -q mysql
        echo "mysqlc: mysql client is not installed" >&2
        return 127
    end

    mysql \
        --host="$argv[1]" \
        --port="$argv[2]" \
        --user="$argv[3]" \
        --password="$argv[4]" \
        --database="$argv[5]" \
        --default-character-set=utf8mb4
end
