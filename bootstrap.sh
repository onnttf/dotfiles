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
    BOLD=''
    BLUE=''
    NC=''
fi

info() { printf " · %s\n" "$*"; }
success() { printf " ✓ %s\n" "$*"; }
warn() { printf " ! %s\n" "$*"; }
error() { printf " ✗ %s\n" "$*" >&2; }
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

header "packages"
if [[ -f "$DOTFILES_DIR/Brewfile" ]]; then
    brew bundle --file "$DOTFILES_DIR/Brewfile"
else
    PACKAGES=(git fish neovim tree-sitter ripgrep fd fzf)

    for package in "${PACKAGES[@]}"; do
        if brew list --versions "$package" >/dev/null 2>&1; then
            success "$package already installed"
        else
            info "installing $package"
            brew install "$package"
            success "$package installed"
        fi
    done
fi

header "fish shell"
FISH_PATH="${BREW_PREFIX}/bin/fish"

if [[ ! -x "$FISH_PATH" ]]; then
    error "fish not found at $FISH_PATH"
    exit 1
fi

if ! grep -qxF -- "$FISH_PATH" /etc/shells; then
    echo "$FISH_PATH" | sudo tee -a /etc/shells >/dev/null
fi

CURRENT_SHELL="$(dscl . -read ~/ UserShell | awk '{print $2}')"

if [[ "$CURRENT_SHELL" == "$FISH_PATH" ]]; then
    success "default shell already fish"
elif chsh -s "$FISH_PATH"; then
    success "default shell set to fish"
else
    warn "could not change default shell; run manually: chsh -s $FISH_PATH"
fi

header "ssh key"
SSH_KEY="$HOME/.ssh/id_ed25519"
mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"

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
        info " $line"
    done <"${SSH_KEY}.pub"
fi

header "config symlinks"
link() {
    local src="$1"
    local dest="$2"

    if [[ ! -e "$src" ]]; then
        warn "source missing: $src"
        return 1
    fi

    mkdir -p "$(dirname "$dest")"

    if [[ -L "$dest" && "$(readlink "$dest")" == "$src" ]]; then
        success "linked already: $dest"
        return 0
    fi

    if [[ -e "$dest" || -L "$dest" ]]; then
        local backup="${dest}.bak.$(date +%Y%m%d%H%M%S)"
        mv -- "$dest" "$backup"
        info "backed up: $dest -> $backup"
    fi

    ln -s "$src" "$dest"
    success "linked: $dest -> $src"
}

setup_gitconfig_include() {
    local dest="$HOME/.gitconfig"
    local include_path="$DOTFILES_DIR/git/gitconfig"

    if [[ -L "$dest" ]]; then
        local backup="${dest}.bak.$(date +%Y%m%d%H%M%S)"
        mv -- "$dest" "$backup"
        info "backed up symlink: $dest -> $backup"
    fi

    touch "$dest"

    if git config --global --get-all include.path 2>/dev/null | grep -qxF "$include_path"; then
        success "gitconfig include already present: $dest"
        return 0
    fi

    git config --global --add include.path "$include_path"
    success "gitconfig include added: $include_path"
}

setup_git_ignore() {
    local src="$DOTFILES_DIR/git/ignore"
    local dest="$HOME/.config/git/ignore"

    if [[ ! -f "$src" ]]; then
        warn "git ignore template missing: $src"
        return 0
    fi

    mkdir -p "$(dirname "$dest")"

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

setup_gitconfig_include
setup_git_ignore

link "$DOTFILES_DIR/fish/conf.d" "$HOME/.config/fish/conf.d"
link "$DOTFILES_DIR/fish/functions" "$HOME/.config/fish/functions"
link "$DOTFILES_DIR/nvim" "$HOME/.config/nvim"

header "machine-local scaffolds"
GITCONFIG_LOCAL="$HOME/.gitconfig.local"

if [[ -e "$GITCONFIG_LOCAL" ]]; then
    success "exists, leaving alone: $GITCONFIG_LOCAL"
else
    cat >"$GITCONFIG_LOCAL" <<'LOCAL_GITCONFIG'
# Machine-local Git overrides.
# Loaded from ~/.gitconfig via [include].
# This file is not tracked by the dotfiles repository.

# [user]
#     email = you@example.com
LOCAL_GITCONFIG
    success "scaffolded: $GITCONFIG_LOCAL"
fi

FISH_LOCAL="$HOME/.config/fish/local.fish"
mkdir -p "$(dirname "$FISH_LOCAL")"

if [[ -e "$FISH_LOCAL" ]]; then
    success "exists, leaving alone: $FISH_LOCAL"
else
    cat >"$FISH_LOCAL" <<'LOCAL_FISH'
# Machine-local fish overrides.
# Sourced by conf.d/99-local.fish.
# This file is not tracked by the dotfiles repository.

# fish_add_path -g "$HOME/bin"
# set -gx EDITOR nvim
LOCAL_FISH
    success "scaffolded: $FISH_LOCAL"
fi

header "bootstrap complete"
info "open a new terminal to apply shell changes"
