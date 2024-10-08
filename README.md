# Dotfiles

These are my personal **dotfiles** used to manage and share my terminal and tool configurations. Below are detailed explanations of some key features and components of the project.

## Features

### Shell

- [Fish](https://fishshell.com/): Fish is a smart and user-friendly command line shell for Linux, macOS, and the rest of the family. Autosuggestions. The configuration file is in [fish](./config/fish).

### Terminal

- [WezTerm](https://github.com/wez/wezterm): A GPU-accelerated cross-platform terminal emulator and multiplexer written by @wez and implemented in Rust. The configuration file is in [wezterm](./config/wezterm).

### Editor

- [Neovim](https://neovim.io/): Provides a consistent editing experience, and the configuration file is in [nvim](./config/nvim).

### Git

- [Git](https://git-scm.com/): Offers some commonly used Git aliases and settings, simplifying Git operations. The configuration file is in [git](./config/git).

### System Information Display

- [Neofetch](https://github.com/dylanaraps/neofetch): Displays system information in the terminal, and the configuration file is in [neofetch](./config/neofetch).

### Scripts

- The [scripts](./config/scripts) contains some common scripts for installing software, setting up environments, etc.The scripts directory contains some common scripts for installing software, setting up environments, etc.

## Installation

To set up these dotfiles on a new system, run:

```shell
/bin/bash -c "$(curl -fsSL https://github.com/onnttf/dotfiles/raw/main/bootstrap.sh)"
```

## Customization

Feel free to fork this repository and modify the configurations to suit your needs. After making changes, run the installation script to apply them.

## Contribution

If you find any issues or have suggestions for improvements, please open an issue or submit a pull request on GitHub.

## License

MIT License. See the [LICENSE](./LICENSE) file for details.
