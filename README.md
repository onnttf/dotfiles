# dotfiles

A small macOS dotfiles setup for Git, Ghostty, fish, Neovim, and everyday developer tooling.

## Usage

```sh
git clone https://github.com/onnttf/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./bootstrap.sh
```

Bootstrap prints its planned operations before making changes. Type exactly `yes` to apply them; any other input cancels. It requires macOS and an interactive terminal to apply changes.

## Deployment

Bootstrap:

- Installs Homebrew if needed and installs the packages in `Brewfile`.
- Adds Homebrew shellenv to `~/.zprofile` when missing.
- Registers the Homebrew fish executable in `/etc/shells` and tries to make it the default shell.
- Creates an ed25519 SSH key if `~/.ssh/id_ed25519` does not exist.
- Copies `git/gitconfig` to `~/.gitconfig`.
- Copies `git/ignore` to `~/.config/git/ignore`.
- Copies `ghostty/config.ghostty` to `~/.config/ghostty/config.ghostty`.
- Copies `fish/conf.d`, `fish/functions`, and `nvim` into `~/.config`.

Configuration is deployed as ordinary files and directories. If a target path is a symlink, bootstrap stops; handle that path manually before deploying. Matching files and directories are skipped; if every check passes without changes, bootstrap exits immediately.

Before replacing a path, bootstrap moves it to `.bak.YYYYmmddHHMMSS` alongside the original. If that name is occupied, it adds a numeric suffix such as `.1`. If the chosen backup path becomes occupied after planning, bootstrap stops so you can rerun it with a fresh plan.

Directories are replaced as a whole. Files found only on the machine move into the directory backup too. For example, machine-specific fish functions must be restored from the backup after deployment.

## Maintaining configuration

Synchronize the repository and deployed configuration manually:

- After editing shared settings in the repository, run `./bootstrap.sh` to deploy them.
- After editing deployed files, review the differences and copy the shared settings you want to keep back into the repository before deploying again.
- Keep passwords, company settings, and other private configuration on the machine. Preserve and reapply those settings when bootstrap replaces their containing file or directory.
- Review the diff before committing.

`git/gitconfig` contains the default personal identity and shared Git behavior. Company URL rewrites, directory-specific identity rules, and machine-specific integrations belong in the machine's `~/.gitconfig`. The conditional work identity file `~/.gitconfig-zyb` stays on the machine and is not managed by bootstrap. Replacing `~/.gitconfig` also replaces its conditional include rules, so restore those rules after deployment.

Application-generated settings in `~/.config/fish/config.fish`, including Docker Desktop's PATH setup, remain on the machine. Bootstrap does not manage that file or create generic local override files.

## Migrating old local overrides

`~/.gitconfig.local` and `~/.config/fish/local.fish` are no longer loaded by the repository configuration. Bootstrap does not migrate or delete them.

Save any settings you still need before deploying. Move shared, non-private settings into the repository first. After deployment, restore machine-specific Git settings into `~/.gitconfig` and fish settings into the appropriate configuration or function files.
