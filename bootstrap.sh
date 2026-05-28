#!/usr/bin/env bash

set -euo pipefail
IFS=$'\n\t'

[[ "$(uname)" == "Darwin" ]] || {
	printf "error: this script requires macOS\n" >&2
	exit 1
}

if [[ -t 1 ]]; then
	BOLD=$'\033[1m'
	BLUE=$'\033[0;34m'
	NC=$'\033[0m'
else
	BOLD='' BLUE='' NC=''
fi

info() { printf "  · %s\n" "$*"; }
success() { printf "  ✓ %s\n" "$*"; }
warn() { printf "  ! %s\n" "$*"; }
error() { printf "  ✗ %s\n" "$*" >&2; }
header() { printf "\n%s==> %s%s\n" "${BOLD}${BLUE}" "$*" "${NC}"; }

DOTFILES_REPO="https://github.com/onnttf/dotfiles.git"

if [[ -n "${BASH_SOURCE[0]:-}" && -f "${BASH_SOURCE[0]:-}" ]]; then
	DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
else
	DOTFILES_DIR="$HOME/.dotfiles"
	if [[ ! -d "$DOTFILES_DIR" ]]; then
		header "clone dotfiles"
		info "cloning $DOTFILES_REPO -> $DOTFILES_DIR"
		git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
	fi
	exec bash "$DOTFILES_DIR/bootstrap.sh"
fi

info "dotfiles root: $DOTFILES_DIR"

header "homebrew"

if ! command -v brew >/dev/null 2>&1; then
	TMP_BREW="$(mktemp -t install_brew.XXXXXX)"
	trap 'rm -f "$TMP_BREW"' EXIT
	curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh -o "$TMP_BREW"
	bash "$TMP_BREW"
	trap - EXIT
	rm -f "$TMP_BREW"
fi

BREW_PREFIX=$([[ "$(uname -m)" == "arm64" ]] && echo "/opt/homebrew" || echo "/usr/local")

if ! grep -qF "brew shellenv" "$HOME/.zprofile" 2>/dev/null; then
	printf 'eval "$(%s/bin/brew shellenv)"\n' "$BREW_PREFIX" >>"$HOME/.zprofile"
fi
eval "$("${BREW_PREFIX}/bin/brew" shellenv)"
success "homebrew ready at ${BREW_PREFIX}"

header "fish shell"

if ! brew list --versions fish >/dev/null 2>&1; then
	brew install fish
fi
success "fish installed"

FISH_PATH="${BREW_PREFIX}/bin/fish"

if ! grep -qxF -- "$FISH_PATH" /etc/shells; then
	echo "$FISH_PATH" | sudo tee -a /etc/shells >/dev/null
fi

CURRENT_SHELL="$(dscl . -read ~/ UserShell | awk '{print $2}')"
if [[ "$CURRENT_SHELL" == "$FISH_PATH" ]]; then
	success "default shell already fish"
elif chsh -s "$FISH_PATH"; then
	success "default shell set to fish"
else
	warn "could not change default shell (may need manual chsh)"
fi

header "packages"

PACKAGES=(git neovim tree-sitter-cli ripgrep)
for pkg in "${PACKAGES[@]}"; do
	if brew list --versions "$pkg" >/dev/null 2>&1; then
		success "$pkg already installed"
	else
		info "installing $pkg"
		if brew install "$pkg"; then
			success "$pkg installed"
		else
			error "failed to install $pkg"
		fi
	fi
done

header "ssh key"

SSH_KEY="$HOME/.ssh/id_ed25519"

if [[ -f "$SSH_KEY" ]]; then
	success "ssh key exists at $SSH_KEY"
else
	info "generating ssh key at $SSH_KEY"
	if ssh-keygen -t ed25519 -f "$SSH_KEY" -C "$USER@$(hostname)" -N ""; then
		success "ssh key generated"
	else
		error "failed to generate ssh key"
	fi
fi

if [[ -f "${SSH_KEY}.pub" ]]; then
	info "public key:"
	while IFS= read -r line; do
		info "  $line"
	done <"${SSH_KEY}.pub"
fi

header "config symlinks"

link() {
	local src="$1" dest="$2"

	if [[ ! -e "$src" ]]; then
		warn "source missing: $src"
		return 1
	fi

	mkdir -p "$(dirname "$dest")"

	if [[ -L "$dest" && "$(readlink "$dest")" == "$src" ]]; then
		success "linked (already): $dest"
		return 0
	fi

	if [[ -e "$dest" || -L "$dest" ]]; then
		local bak="${dest}.bak.$(date +%Y%m%d%H%M%S)"
		mv -- "$dest" "$bak"
		info "backed up: $dest -> $bak"
	fi

	ln -s "$src" "$dest"
	success "linked: $dest -> $src"
}

setup_gitconfig_include() {
	local dest="$HOME/.gitconfig"
	local include_path="$DOTFILES_DIR/git/gitconfig"

	if [[ -L "$dest" ]]; then
		local bak="${dest}.bak.$(date +%Y%m%d%H%M%S)"
		mv -- "$dest" "$bak"
		info "backed up symlink: $dest -> $bak"
	fi

	cat >"$dest" <<EOF
# Managed by dotfiles bootstrap.
# Local tools may edit this file; shared settings live in:
# $include_path

[include]
	path = $include_path
EOF
	success "created gitconfig include: $dest"
}

ensure_gitconfig_include() {
	local dest="$HOME/.gitconfig"
	local include_path="$DOTFILES_DIR/git/gitconfig"

	if git config --file "$dest" --get-all include.path 2>/dev/null | grep -qxF "$include_path"; then
		success "gitconfig include already present: $dest"
		return 0
	fi

	printf "\n" >>"$dest"
	cat >>"$dest" <<EOF
# Managed by dotfiles bootstrap.
# Local tools may edit this file; shared settings live in:
# $include_path

[include]
	path = $include_path
EOF
	success "added gitconfig include: $dest"
}

if [[ -f "$HOME/.gitconfig" && ! -L "$HOME/.gitconfig" ]]; then
	ensure_gitconfig_include
else
	setup_gitconfig_include
fi

setup_git_ignore() {
	local src="$DOTFILES_DIR/git/ignore"
	local dest="$HOME/.config/git/ignore"

	if [[ ! -e "$src" ]]; then
		warn "source missing: $src"
		return 1
	fi

	mkdir -p "$(dirname "$dest")"

	if [[ -L "$dest" ]]; then
		local bak="${dest}.bak.$(date +%Y%m%d%H%M%S)"
		mv -- "$dest" "$bak"
		info "backed up symlink: $dest -> $bak"
	fi

	if [[ ! -e "$dest" ]]; then
		cp "$src" "$dest"
		success "created git ignore from template: $dest"
		return 0
	fi

	local added=0
	while IFS= read -r line || [[ -n "$line" ]]; do
		[[ -z "$line" ]] && continue
		if ! grep -qxF "$line" "$dest"; then
			if [[ "$added" -eq 0 ]]; then
				printf "\n# Added by dotfiles bootstrap.\n" >>"$dest"
			fi
			printf "%s\n" "$line" >>"$dest"
			added=1
		fi
	done <"$src"

	if [[ "$added" -eq 1 ]]; then
		success "updated git ignore from template: $dest"
	else
		success "git ignore already up to date: $dest"
	fi
}

setup_git_ignore
link "$DOTFILES_DIR/fish/conf.d" "$HOME/.config/fish/conf.d"
link "$DOTFILES_DIR/fish/functions" "$HOME/.config/fish/functions"
link "$DOTFILES_DIR/nvim" "$HOME/.config/nvim"

header "machine-local scaffolds"

GITCONFIG_LOCAL="$HOME/.gitconfig.local"
if [[ -e "$GITCONFIG_LOCAL" ]]; then
	success "exists, leaving alone: $GITCONFIG_LOCAL"
else
	cat >"$GITCONFIG_LOCAL" <<'EOF'
# Machine-local git overrides.
# Loaded from ~/.gitconfig via [include].
# This file is not tracked by the dotfiles repository.

EOF
	success "scaffolded: $GITCONFIG_LOCAL"
fi

FISH_LOCAL="$HOME/.config/fish/local.fish"
mkdir -p "$(dirname "$FISH_LOCAL")"
if [[ -e "$FISH_LOCAL" ]]; then
	success "exists, leaving alone: $FISH_LOCAL"
else
	cat >"$FISH_LOCAL" <<'EOF'
# Machine-local fish overrides.
# Sourced by conf.d/99-local.fish.
# This file is not tracked by the dotfiles repository.

EOF
	success "scaffolded: $FISH_LOCAL"
fi

header "bootstrap complete"
info "open a new terminal to apply shell changes"
