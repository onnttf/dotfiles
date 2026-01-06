function rmds --description "Remove .DS_Store files below the current directory"
    find . -name .DS_Store -type f -delete
end
