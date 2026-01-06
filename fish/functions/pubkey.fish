function pubkey --description "Print the first available SSH public key"
    for key in ~/.ssh/id_ed25519.pub ~/.ssh/id_rsa.pub
        if test -r "$key"
            cat "$key"
            return 0
        end
    end

    echo "pubkey: no supported SSH public key found" >&2
    return 1
end
