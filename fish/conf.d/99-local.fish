# Sources a non-tracked file for per-machine settings.
# Create ~/.config/fish/local.fish for custom PATH, aliases, or secrets.

set -l local_file $HOME/.config/fish/local.fish
test -r $local_file; and source $local_file
