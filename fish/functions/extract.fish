function extract --description "Extract a common archive by extension"
    if test (count $argv) -ne 1
        echo "Usage: extract <archive>" >&2
        return 1
    end

    set -l file "$argv[1]"

    if not test -f "$file"
        echo "extract: $file: not a file" >&2
        return 1
    end

    switch "$file"
        case "*.tar.bz2" "*.tbz2"
            require_command tar; or return
            tar xjf "$file"
        case "*.tar.gz" "*.tgz"
            require_command tar; or return
            tar xzf "$file"
        case "*.tar.xz" "*.txz"
            require_command tar; or return
            tar xJf "$file"
        case "*.tar"
            require_command tar; or return
            tar xf "$file"
        case "*.bz2"
            require_command bunzip2; or return
            bunzip2 "$file"
        case "*.gz"
            require_command gunzip; or return
            gunzip "$file"
        case "*.xz"
            require_command xz; or return
            xz -d "$file"
        case "*.zip"
            require_command unzip; or return
            unzip "$file"
        case "*.rar"
            require_command unrar; or return
            unrar x "$file"
        case "*.7z"
            require_command 7z; or return
            7z x "$file"
        case "*"
            echo "extract: unknown archive format: $file" >&2
            return 1
    end
end
