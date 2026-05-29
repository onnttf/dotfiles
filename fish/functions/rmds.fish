function rmds --description "Remove .DS_Store files below the current directory"
    require_command find; or return

    find . -name .DS_Store -type f -delete
end
