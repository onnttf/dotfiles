function ip --description "Show IPv4 addresses by interface"
    ifconfig | awk '/inet / && !/inet6/ { print $2, $1 }'
end
