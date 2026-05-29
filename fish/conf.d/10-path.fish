# fish_add_path is idempotent: it skips entries that already exist.
fish_add_path -g "$HOME/.local/bin"
fish_add_path -g "$HOME/.git-ai/bin"

if command -q go
    fish_add_path -g "$HOME/go/bin"
end

set -gx BUN_INSTALL "$HOME/.bun"
fish_add_path -g "$BUN_INSTALL/bin"
