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
BREW_PREFIX=$([[ "$(uname -m)" == "arm64" ]] && echo "/opt/homebrew" || echo "/usr/local")
FISH_PATH="${BREW_PREFIX}/bin/fish"
SSH_KEY="$HOME/.ssh/id_ed25519"
GITCONFIG_LOCAL="$HOME/.gitconfig.local"
FISH_LOCAL="$HOME/.config/fish/local.fish"

PLAN_HOME=()
PLAN_SHELL=()
PLAN_SSH=()
PLAN_CONFIG=()
PLAN_LOCAL=()
CHANGE_COUNT=0

NEED_CLONE=0
NEED_INSTALL_HOMEBREW=0
NEED_ZPROFILE_BREW=0
NEED_PACKAGES=0
NEED_FISH_SHELLS=0
NEED_CHSH=0
NEED_SSH_DIR=0
NEED_SSH_KEY=0
NEED_GITCONFIG_LOCAL=0
NEED_FISH_LOCAL=0

CONFIG_SRC=()
CONFIG_DEST=()
CONFIG_ACTION=()
CONFIG_BACKUP=()

add_plan() {
    local group="$1"
    local kind="$2"
    local message="$3"
    local line

    line="$(printf "%-6s %s" "$kind" "$message")"

    case "$group" in
        homebrew) PLAN_HOME+=("$line") ;;
        shell) PLAN_SHELL+=("$line") ;;
        ssh) PLAN_SSH+=("$line") ;;
        config) PLAN_CONFIG+=("$line") ;;
        local) PLAN_LOCAL+=("$line") ;;
        *) error "unknown plan group: $group"; exit 1 ;;
    esac

    if [[ "$kind" == "do" || "$kind" == "warn" ]]; then
        CHANGE_COUNT=$((CHANGE_COUNT + 1))
    fi
}

print_group() {
    local title="$1"
    shift

    [[ "$#" -gt 0 ]] || return 0

    header "$title"
    local line
    for line in "$@"; do
        printf " %s\n" "$line"
    done
}

print_plan() {
    header "planned operations"
    info "dotfiles root: $DOTFILES_DIR"

    print_group "homebrew" "${PLAN_HOME[@]}"
    print_group "fish shell" "${PLAN_SHELL[@]}"
    print_group "ssh key" "${PLAN_SSH[@]}"
    print_group "config files" "${PLAN_CONFIG[@]}"
    print_group "machine-local scaffolds" "${PLAN_LOCAL[@]}"
}

confirm_plan() {
    if [[ "$CHANGE_COUNT" -eq 0 ]]; then
        success "nothing to change"
        return 1
    fi

    if ! { exec 3<>/dev/tty; } 2>/dev/null; then
        warn "no TTY available; not applying planned operations"
        return 1
    fi

    printf "\nType yes to apply these changes: " >&3

    local answer
    IFS= read -r answer <&3
    exec 3>&-

    if [[ "$answer" != "yes" ]]; then
        warn "aborted"
        return 1
    fi

    return 0
}

plan_clone_or_exec() {
    if [[ -n "${BASH_SOURCE[0]:-}" && -f "${BASH_SOURCE[0]:-}" ]]; then
        DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
        return 0
    fi

    DOTFILES_DIR="$HOME/.dotfiles"

    if [[ -d "$DOTFILES_DIR" ]]; then
        exec bash "$DOTFILES_DIR/bootstrap.sh"
    fi

    NEED_CLONE=1
    add_plan homebrew do "clone $DOTFILES_REPO -> $DOTFILES_DIR"
}

apply_clone_or_exec() {
    [[ "$NEED_CLONE" -eq 1 ]] || return 0

    header "clone dotfiles"
    git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
    exec bash "$DOTFILES_DIR/bootstrap.sh"
}

plan_homebrew() {
    if command -v brew >/dev/null 2>&1; then
        add_plan homebrew skip "homebrew already installed"
    else
        NEED_INSTALL_HOMEBREW=1
        add_plan homebrew do "install homebrew"
    fi

    if grep -qF "brew shellenv" "$HOME/.zprofile" 2>/dev/null; then
        add_plan homebrew skip "brew shellenv already present in $HOME/.zprofile"
    else
        NEED_ZPROFILE_BREW=1
        add_plan homebrew do "append brew shellenv to $HOME/.zprofile"
    fi

    if [[ -f "$DOTFILES_DIR/Brewfile" ]]; then
        if command -v brew >/dev/null 2>&1 && brew bundle check --file "$DOTFILES_DIR/Brewfile" >/dev/null 2>&1; then
            add_plan homebrew skip "Brewfile packages already installed"
        else
            NEED_PACKAGES=1
            add_plan homebrew do "run brew bundle --file $DOTFILES_DIR/Brewfile"
        fi
    else
        local missing=()
        local package

        for package in git fish neovim tree-sitter ripgrep fd fzf; do
            if ! command -v brew >/dev/null 2>&1 || ! brew list --versions "$package" >/dev/null 2>&1; then
                missing+=("$package")
            fi
        done

        if [[ "${#missing[@]}" -eq 0 ]]; then
            add_plan homebrew skip "fallback packages already installed"
        else
            local missing_text
            missing_text="$(printf "%s " "${missing[@]}")"
            missing_text="${missing_text% }"
            NEED_PACKAGES=1
            add_plan homebrew do "install fallback packages: $missing_text"
        fi
    fi
}

apply_homebrew() {
    header "homebrew"

    if [[ "$NEED_INSTALL_HOMEBREW" -eq 1 ]]; then
        local tmp_brew
        tmp_brew="$(mktemp -t install_brew.XXXXXX)"
        trap 'rm -f "$tmp_brew"' EXIT
        curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh -o "$tmp_brew"
        bash "$tmp_brew"
        trap - EXIT
        rm -f "$tmp_brew"
    fi

    if [[ "$NEED_ZPROFILE_BREW" -eq 1 ]]; then
        printf 'eval "$(%s/bin/brew shellenv)"\n' "$BREW_PREFIX" >>"$HOME/.zprofile"
    fi

    eval "$("${BREW_PREFIX}/bin/brew" shellenv)"
    success "homebrew ready at ${BREW_PREFIX}"

    header "packages"
    if [[ "$NEED_PACKAGES" -ne 1 ]]; then
        success "packages already installed"
        return 0
    fi

    if [[ -f "$DOTFILES_DIR/Brewfile" ]]; then
        brew bundle --file "$DOTFILES_DIR/Brewfile"
    else
        local package
        for package in git fish neovim tree-sitter ripgrep fd fzf; do
            if brew list --versions "$package" >/dev/null 2>&1; then
                success "$package already installed"
            else
                info "installing $package"
                brew install "$package"
                success "$package installed"
            fi
        done
    fi
}

plan_fish_shell() {
    if [[ -x "$FISH_PATH" ]]; then
        add_plan shell skip "fish exists at $FISH_PATH"
    else
        add_plan shell warn "fish not found at $FISH_PATH; apply will stop if Brewfile does not install it"
    fi

    if grep -qxF -- "$FISH_PATH" /etc/shells 2>/dev/null; then
        add_plan shell skip "$FISH_PATH already present in /etc/shells"
    else
        NEED_FISH_SHELLS=1
        add_plan shell do "append $FISH_PATH to /etc/shells"
    fi

    local current_shell
    current_shell="$(dscl . -read ~/ UserShell 2>/dev/null | awk '{print $2}' || true)"

    if [[ "$current_shell" == "$FISH_PATH" ]]; then
        add_plan shell skip "default shell already fish"
    else
        NEED_CHSH=1
        add_plan shell do "change default shell to $FISH_PATH"
    fi
}

apply_fish_shell() {
    header "fish shell"

    if [[ ! -x "$FISH_PATH" ]]; then
        error "fish not found at $FISH_PATH"
        exit 1
    fi

    if [[ "$NEED_FISH_SHELLS" -eq 1 ]]; then
        echo "$FISH_PATH" | sudo tee -a /etc/shells >/dev/null
    fi

    if [[ "$NEED_CHSH" -eq 1 ]]; then
        if chsh -s "$FISH_PATH"; then
            success "default shell set to fish"
        else
            warn "could not change default shell; run manually: chsh -s $FISH_PATH"
        fi
    else
        success "default shell already fish"
    fi
}

plan_ssh_key() {
    if [[ -d "$HOME/.ssh" ]]; then
        add_plan ssh skip "$HOME/.ssh exists"
    else
        NEED_SSH_DIR=1
        add_plan ssh do "create $HOME/.ssh with 700 permissions"
    fi

    if [[ -f "$SSH_KEY" ]]; then
        add_plan ssh skip "ssh key exists at $SSH_KEY"
    else
        NEED_SSH_KEY=1
        add_plan ssh do "generate ed25519 ssh key at $SSH_KEY"
    fi
}

apply_ssh_key() {
    header "ssh key"

    if [[ "$NEED_SSH_DIR" -eq 1 || ! -d "$HOME/.ssh" ]]; then
        mkdir -p "$HOME/.ssh"
    fi
    chmod 700 "$HOME/.ssh"

    if [[ "$NEED_SSH_KEY" -eq 1 ]]; then
        info "generating ssh key at $SSH_KEY"

        if ssh-keygen -t ed25519 -f "$SSH_KEY" -C "$USER@$(hostname)" -N ""; then
            success "ssh key generated"
        else
            error "failed to generate ssh key"
        fi
    else
        success "ssh key exists at $SSH_KEY"
    fi

    if [[ -f "${SSH_KEY}.pub" ]]; then
        info "public key:"
        while IFS= read -r line; do
            info " $line"
        done <"${SSH_KEY}.pub"
    fi
}

plan_config_copy() {
    local src="$1"
    local dest="$2"
    local action="create"
    local backup=""

    if [[ ! -e "$src" ]]; then
        add_plan config warn "source missing: $src"
        return 0
    fi

    if [[ ! -e "$dest" && ! -L "$dest" ]]; then
        add_plan config do "copy $src -> $dest"
    elif [[ -L "$dest" ]]; then
        action="replace"
        backup="${dest}.bak.$(date +%Y%m%d%H%M%S)"
        add_plan config do "backup symlink $dest -> $backup; copy $src -> $dest"
    elif diff -qr "$src" "$dest" >/dev/null 2>&1; then
        action="skip"
        add_plan config skip "$dest already matches $src"
    else
        action="replace"
        backup="${dest}.bak.$(date +%Y%m%d%H%M%S)"
        add_plan config do "backup $dest -> $backup; copy $src -> $dest"
    fi

    CONFIG_SRC+=("$src")
    CONFIG_DEST+=("$dest")
    CONFIG_ACTION+=("$action")
    CONFIG_BACKUP+=("$backup")
}

plan_config_files() {
    plan_config_copy "$DOTFILES_DIR/git/gitconfig" "$HOME/.gitconfig"
    plan_config_copy "$DOTFILES_DIR/git/ignore" "$HOME/.config/git/ignore"
    plan_config_copy "$DOTFILES_DIR/fish/conf.d" "$HOME/.config/fish/conf.d"
    plan_config_copy "$DOTFILES_DIR/fish/functions" "$HOME/.config/fish/functions"
    plan_config_copy "$DOTFILES_DIR/nvim" "$HOME/.config/nvim"
}

apply_config_files() {
    header "config files"

    local i
    for ((i = 0; i < ${#CONFIG_SRC[@]}; i++)); do
        local src="${CONFIG_SRC[$i]}"
        local dest="${CONFIG_DEST[$i]}"
        local action="${CONFIG_ACTION[$i]}"
        local backup="${CONFIG_BACKUP[$i]}"

        [[ "$action" != "skip" ]] || {
            success "already up to date: $dest"
            continue
        }

        mkdir -p "$(dirname "$dest")"

        if [[ "$action" == "replace" ]]; then
            mv -- "$dest" "$backup"
            info "backed up: $dest -> $backup"
        fi

        ditto "$src" "$dest"
        success "copied: $src -> $dest"
    done
}

plan_local_scaffolds() {
    if [[ -e "$GITCONFIG_LOCAL" ]]; then
        add_plan local skip "$GITCONFIG_LOCAL exists"
    else
        NEED_GITCONFIG_LOCAL=1
        add_plan local do "create $GITCONFIG_LOCAL"
    fi

    if [[ -e "$FISH_LOCAL" ]]; then
        add_plan local skip "$FISH_LOCAL exists"
    else
        NEED_FISH_LOCAL=1
        add_plan local do "create $FISH_LOCAL"
    fi
}

apply_local_scaffolds() {
    header "machine-local scaffolds"

    if [[ "$NEED_GITCONFIG_LOCAL" -eq 1 ]]; then
        cat >"$GITCONFIG_LOCAL" <<'LOCAL_GITCONFIG'
# Machine-local Git overrides.
# Loaded from ~/.gitconfig via [include].
# This file is not tracked by the dotfiles repository.

# [user]
#     email = you@example.com
LOCAL_GITCONFIG
        success "scaffolded: $GITCONFIG_LOCAL"
    else
        success "exists, leaving alone: $GITCONFIG_LOCAL"
    fi

    mkdir -p "$(dirname "$FISH_LOCAL")"

    if [[ "$NEED_FISH_LOCAL" -eq 1 ]]; then
        cat >"$FISH_LOCAL" <<'LOCAL_FISH'
# Machine-local fish overrides.
# Sourced by conf.d/99-local.fish.
# This file is not tracked by the dotfiles repository.

# fish_add_path -g "$HOME/bin"
# set -gx EDITOR nvim
LOCAL_FISH
        success "scaffolded: $FISH_LOCAL"
    else
        success "exists, leaving alone: $FISH_LOCAL"
    fi
}

plan_all() {
    plan_clone_or_exec

    if [[ "$NEED_CLONE" -eq 1 ]]; then
        return 0
    fi

    plan_homebrew
    plan_fish_shell
    plan_ssh_key
    plan_config_files
    plan_local_scaffolds
}

apply_all() {
    apply_clone_or_exec
    apply_homebrew
    apply_fish_shell
    apply_ssh_key

    apply_config_files
    apply_local_scaffolds

    header "bootstrap complete"
    info "open a new terminal to apply shell changes"
}

plan_all
print_plan

if confirm_plan; then
    apply_all
fi
