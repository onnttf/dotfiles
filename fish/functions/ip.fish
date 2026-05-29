function ip --description "Show IPv4 addresses by interface"
    require_command ifconfig; or return
    require_command awk; or return

    ifconfig | awk '/inet / && !/inet6/ { print $2, $1 }'
end
