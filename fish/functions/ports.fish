function ports --description "List TCP listeners"
    require_command lsof; or return

    lsof -nP -iTCP -sTCP:LISTEN
end
