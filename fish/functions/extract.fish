function extract --description "Extract a common archive by extension"
    if test (count $argv) -ne 1
        echo "Usage: extract <file>" >&2
        return 1
    end

    set -l file "$argv[1]"
    if not test -f "$file"
        echo "extract: $file: not a file" >&2
        return 1
    end

    switch "$file"
        case "*.tar.bz2" "*.tbz2"
            tar xjf "$file"
        case "*.tar.gz" "*.tgz"
            tar xzf "$file"
        case "*.tar.xz" "*.txz"
            tar xJf "$file"
        case "*.tar"
            tar xf "$file"
        case "*.bz2"
            bunzip2 "$file"
        case "*.gz"
            gunzip "$file"
        case "*.xz"
            xz -d "$file"
        case "*.zip"
            unzip "$file"
        case "*.rar"
            unrar x "$file"
        case "*.7z"
            7z x "$file"
        case "*"
            echo "extract: unknown archive format: $file" >&2
            return 1
    end
end
