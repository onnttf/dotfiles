# Keep integrations lightweight and guarded so missing tools are silently skipped.
if test -r "$HOME/.orbstack/shell/init2.fish"
    source "$HOME/.orbstack/shell/init2.fish"
end
