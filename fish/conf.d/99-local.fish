# Source non-tracked per-machine settings.
set -l local_file "$HOME/.config/fish/local.fish"

test -r "$local_file"; and source "$local_file"
