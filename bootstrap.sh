#!/bin/bash

# Set script to exit on any error
set -e

# URL of the dotfiles repository
dotfiles_repo="https://github.com/onnttf/dotfiles.git"
# Paths
config_path="$HOME/.config"
dotfiles_path="$HOME/dotfiles"
# Timestamp for backup purposes
now=$(date +%Y-%m-%d_%H:%M:%S)

# Function to handle errors and exit
on_error() {
    echo "Error encountered. Exiting..."
    exit 1
}
trap on_error ERR

# Check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to install packages based on the package manager
install_packages() {
    local package_manager=$1
    shift
    local packages=("$@")

    for package in "${packages[@]}"; do
        if ! command_exists "$package"; then
            echo "Installing $package with $package_manager..."
            case "$package_manager" in
            apt-get)
                sudo "$package_manager" install -y "$package"
                ;;
            pacman)
                sudo "$package_manager" -Syu --noconfirm "$package"
                ;;
            dnf)
                sudo "$package_manager" install -y "$package"
                ;;
            *)
                echo "Unsupported package manager. Exiting..."
                exit 1
                ;;
            esac
        fi
    done
}

# Setup for macOS
setup_macos() {
    # Use TUNA mirrors for Homebrew
    export HOMEBREW_BREW_GIT_REMOTE="https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/brew.git"
    export HOMEBREW_CORE_GIT_REMOTE="https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/homebrew-core.git"

    # Install Homebrew if not already installed
    if ! command_exists brew; then
        sudo echo "Homebrew is not installed. Installing Homebrew..."
        NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi

    # Update and upgrade Homebrew and install packages
    echo "Updating and upgrading Homebrew..."
    brew update --auto-update && brew upgrade

    # List of packages to install with Homebrew
    brew_packages=("git" "neovim" "fish" "neofetch" "ripgrep" "node" "golang")
    echo "Installing Homebrew packages: ${brew_packages[*]}"
    brew install "${brew_packages[@]}"

    # Install WezTerm using Homebrew Cask
    echo "Installing WezTerm..."
    brew install --cask wezterm
}

# Setup for Ubuntu
setup_ubuntu() {
    # Backup original sources.list and use TUNA mirrors
    sudo cp /etc/apt/sources.list /etc/apt/sources.list.bak.$(date +%Y%m%d%H%M%S)
    sudo sed -i 's/http:\/\/archive\.ubuntu\.com\/ubuntu\//https:\/\/mirrors.tuna.tsinghua.edu.cn\/ubuntu\//g' /etc/apt/sources.list
    sudo apt-get update
    sudo apt-get upgrade -y
    sudo apt-get install -y software-properties-common

    # Install Fish shell from PPA if not already installed
    if ! command_exists fish; then
        echo "Installing Fish shell..."
        sudo add-apt-repository ppa:fish-shell/release-3 -y
        sudo apt-get update
        sudo apt-get install -y fish
    fi

    # List of packages to install with apt-get
    ubuntu_packages=("curl" "git" "neofetch" "build-essential" "golang" "nodejs" "npm" "ripgrep")
    echo "Installing Ubuntu packages: ${ubuntu_packages[*]}"
    install_packages "apt-get" "${ubuntu_packages[@]}"

    # Install Neovim manually if not already installed
    if ! command_exists nvim; then
        echo "Installing Neovim manually..."
        curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim.appimage
        chmod u+x nvim.appimage
        ./nvim.appimage --appimage-extract
        ./squashfs-root/AppRun --version
        sudo mv squashfs-root /
        sudo ln -s /squashfs-root/AppRun /usr/bin/nvim
        rm nvim.appimage
    fi
}

# Setup for Arch Linux
setup_arch() {
    # Backup original mirrorlist and use TUNA mirrors
    sudo cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak.$now
    echo "Server = https://mirrors.tuna.tsinghua.edu.cn/archlinux/\$repo/os/\$arch" | sudo tee /etc/pacman.d/mirrorlist
    # List of packages to install with pacman
    arch_packages=("curl" "git" "fish" "base-devel" "neovim" "neofetch" "go" "nodejs" "npm" "ripgrep")
    echo "Installing Arch Linux packages: ${arch_packages[*]}"
    install_packages "pacman" "${arch_packages[@]}"
}

# Setup for Fedora
setup_fedora() {
    # List of packages to install with dnf
    fedora_packages=("util-linux-user" "curl" "git" "fish" "gcc" "gcc-c++" "neovim" "neofetch" "golang" "nodejs" "npm" "ripgrep")
    echo "Installing Fedora packages: ${fedora_packages[*]}"
    install_packages "dnf" "${fedora_packages[@]}"
}

# Determine the operating system and run the appropriate setup function
case "$(uname -s)" in
Darwin*)
    setup_macos
    ;;
Linux*)
    if [ -f /etc/os-release ]; then
        source /etc/os-release
        case "$ID" in
        ubuntu)
            setup_ubuntu
            ;;
        fedora)
            setup_fedora
            ;;
        arch)
            setup_arch
            ;;
        *)
            echo "Unsupported Linux distribution. Exiting..."
            exit 1
            ;;
        esac
    else
        echo "Unsupported Linux distribution. Exiting..."
        exit 1
    fi
    ;;
*)
    echo "Unsupported operating system. Exiting..."
    exit 1
    ;;
esac

# Backup existing dotfiles and clone the new dotfiles repository
if [[ -d "$dotfiles_path" ]]; then
    echo "Backing up existing dotfiles to ${dotfiles_path}_$now"
    mv "$dotfiles_path" "${dotfiles_path}_$now"
fi

echo "Cloning dotfiles repository to $dotfiles_path"
mkdir -p "$dotfiles_path"
git clone --depth 1 "$dotfiles_repo" "$dotfiles_path"

# Backup existing config files and copy new config files
if [[ -d "$config_path" ]]; then
    echo "Backing up existing config files to ${config_path}_$now"
    mv "$config_path" "${config_path}_$now"
fi

echo "Copying new config files to $config_path"
mkdir -p "$config_path"
cp -r "$dotfiles_path/config/"* "$config_path/"

# Copy specific Git configuration files
echo "Copying Git configuration files to $HOME"
cp "$dotfiles_path/config/git/gitconfig" "$HOME/.gitconfig"
cp "$dotfiles_path/config/git/gitconfig.company" "$HOME/.gitconfig.company"
cp "$dotfiles_path/config/git/gitignore" "$HOME/.gitignore"

# Change shell to Fish if not already set
if [ "$SHELL" != "$(command -v fish)" ]; then
    echo "Changing default shell to Fish..."
    echo "$(command -v fish)" | sudo tee -a /etc/shells
    sudo chsh -s "$(command -v fish)"
    exec "$(command -v fish)"
fi

echo "Installation and setup complete..."
