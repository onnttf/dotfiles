# dotfiles

A small, opinionated macOS dotfiles setup for Git, fish, Neovim, and everyday developer tooling.

## Usage

Clone the repository and run the bootstrap script:

```sh
git clone https://github.com/onnttf/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./bootstrap.sh
```

The script is macOS-only. It first prints the operations it plans to run, then waits for confirmation. Type exactly `yes` to apply the changes; any other input exits without applying them.

## What bootstrap does

- Installs Homebrew if needed.
- Runs `brew bundle` from `Brewfile`.
- Adds Homebrew shellenv to `~/.zprofile` when missing.
- Adds the Homebrew fish path to `/etc/shells` and tries to set fish as the default shell.
- Creates an ed25519 SSH key if `~/.ssh/id_ed25519` does not exist.
- Copies `git/gitconfig` to `~/.gitconfig`.
- Copies `git/ignore` to `~/.config/git/ignore`.
- Copies `fish/conf.d`, `fish/functions`, and `nvim` into `~/.config`.

Existing config paths that need to be replaced are backed up as `.bak.YYYYmmddHHMMSS` after confirmation.

## Local overrides

Machine-specific settings should live outside the repository:

- Git overrides: `~/.gitconfig.local`
- fish overrides: `~/.config/fish/local.fish`

Bootstrap creates these files only when they do not already exist.

Bootstrap deploys tracked config by copying from this repository to the machine. Editing deployed files such as `~/.gitconfig` or files under `~/.config` will not directly modify the repository. When deployed files already match the repository, bootstrap skips them.
