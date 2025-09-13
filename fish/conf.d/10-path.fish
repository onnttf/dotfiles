# fish_add_path is idempotent: only appends if the entry is missing.

fish_add_path -g "$HOME/.local/bin"

if command -q go
    fish_add_path -g "$HOME/go/bin"
end

set -gx BUN_INSTALL "$HOME/.bun"
fish_add_path -g "$BUN_INSTALL/bin"

fish_add_path -g "$HOME/.git-ai/bin"
