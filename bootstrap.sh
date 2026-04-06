#!/usr/bin/env bash
# bootstrap script for macos dev environment setup (homebrew, fish shell, core packages)

set -eo pipefail

[[ "$(uname)" == "Darwin" ]] || {
    printf "error: this script requires macos\n" >&2
    exit 1
}

if [[ -t 1 ]]; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    BOLD='\033[1m'
    NC='\033[0m'
else
    RED='' GREEN='' YELLOW='' BLUE='' BOLD='' NC=''
fi

info() { printf "  · %s\n" "$*"; }
success() { printf "  ✓ %s\n" "$*"; }
warn() { printf "  ! %s\n" "$*"; }
error() { printf "  ✗ %s\n" "$*" >&2; }
header() { printf "\n%b\n" "${BOLD}${BLUE}==> $*${NC}"; }

DOTFILES_DIR="$HOME/.dotfiles"
DOTFILES_REPO="https://github.com/onnttf/dotfiles.git"

if [[ ! -d "$DOTFILES_DIR" ]]; then
    header "clone dotfiles"

    info "cloning dotfiles from $DOTFILES_REPO"
    git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
    success "dotfiles cloned to $DOTFILES_DIR"

    export DOTFILES="$DOTFILES_DIR"
    bash "$DOTFILES_DIR/bootstrap.sh"
else
    info "dotfiles already cloned, skipping clone"
fi

header "homebrew"

if ! command -v brew >/dev/null 2>&1; then
    TMP_BREW="$(mktemp /tmp/install_brew.XXXXXX.sh)"
    trap 'rm -f "$TMP_BREW"' EXIT
    curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh -o "$TMP_BREW"
    bash "$TMP_BREW"
fi

BREW_PREFIX=$([[ "$(uname -m)" == "arm64" ]] && echo "/opt/homebrew" || echo "/usr/local")

if ! grep -q "brew shellenv" ~/.zprofile 2>/dev/null; then
    echo "eval \"\$(${BREW_PREFIX}/bin/brew shellenv)\"" >>~/.zprofile
fi
eval "$(${BREW_PREFIX}/bin/brew shellenv)"
success "homebrew ready at ${BREW_PREFIX}"

header "fish shell"

if ! brew list --versions fish >/dev/null 2>&1; then
    brew install fish
fi
success "fish ready"

FISH_PATH="${BREW_PREFIX}/bin/fish"

if ! grep -q "$FISH_PATH" /etc/shells; then echo "$FISH_PATH" | sudo tee -a /etc/shells >/dev/null; fi

CURRENT_SHELL="$(dscl . -read ~/ UserShell | awk '{print $2}')"
if [[ "$CURRENT_SHELL" == "$FISH_PATH" ]]; then
    success "default shell already set to fish"
else
    if chsh -s "$FISH_PATH"; then
        success "default shell set to fish"
    else
        warn "failed to change default shell (may require manual intervention)"
    fi
fi

header "packages"

PACKAGES=(git neovim tree-sitter-cli ripgrep)

for pkg in "${PACKAGES[@]}"; do
    if ! brew list --versions "$pkg" >/dev/null 2>&1; then
        info "installing $pkg"
        if ! brew install "$pkg"; then
            error "failed to install $pkg"
        else
            success "$pkg installed"
        fi
    else
        success "$pkg already installed"
    fi
done

header "ssh key"

SSH_KEY="$HOME/.ssh/id_ed25519"

if [[ ! -f "$SSH_KEY" ]]; then
    info "generating new ssh key at $SSH_KEY"
    if ssh-keygen -t ed25519 -f "$SSH_KEY" -C "$USER@$(hostname)" -N ""; then
        success "ssh key generated"
    else
        error "failed to generate ssh key"
    fi
else
    success "ssh key already exists at $SSH_KEY"
fi

PUB_KEY="${SSH_KEY}.pub"

if [[ -f "$PUB_KEY" ]]; then
    info "public key (${PUB_KEY}):"
    while IFS= read -r line; do
        info "  $line"
    done <"$PUB_KEY"
fi

header "configs"

SCRIPT_DIR="$DOTFILES_DIR"

sync_config() {
    local src="$1"
    local dest="$2"
    local dest_dir
    dest_dir="$(dirname "$dest")"

    if [[ ! -e "$src" ]]; then
        warn "source not found: $src"
        return 1
    fi

    if [[ -e "$dest" ]]; then
        mkdir -p "$dest_dir"
        local bak_path="${dest}.bak.$(date +%Y%m%d%H%M%S)"
        cp -R "$dest" "$bak_path"
        info "backup: $bak_path"
        rm -rf "$dest"
    fi

    mkdir -p "$dest_dir"

    if [[ -d "$src" ]]; then
        if ! cp -R "$src" "$dest"; then
            error "failed to copy $src to $dest"
            return 1
        fi
    else
        if ! cp "$src" "$dest"; then
            error "failed to copy $src to $dest"
            return 1
        fi
    fi

    info "synced: $src -> $dest"
}

sync_config "$SCRIPT_DIR/fish" "$HOME/.config/fish"
sync_config "$SCRIPT_DIR/git/gitconfig" "$HOME/.gitconfig"
sync_config "$SCRIPT_DIR/git/gitignore_global" "$HOME/.gitignore_global"
sync_config "$SCRIPT_DIR/nvim" "$HOME/.config/nvim"

success "configs synced"

header "bootstrap complete"
info "restart your terminal to apply changes"
