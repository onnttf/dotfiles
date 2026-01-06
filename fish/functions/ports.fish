function ports --description "List TCP listeners"
    if not command -q lsof
        echo "ports: lsof is not installed" >&2
        return 127
    end

    lsof -nP -iTCP -sTCP:LISTEN
end
