<p align="center">
  <img src="https://github.com/mmmarceleza/dotfiles/assets/58913502/f0033709-a970-4eb8-a124-389b69129bd5" alt="dotfiles"/>
</p>

[![MIT License](https://img.shields.io/badge/License-MIT-green.svg)](https://choosealicense.com/licenses/mit/)

---

# My Links

[![linkedin](https://img.shields.io/badge/linkedin-0A66C2?style=for-the-badge&logo=linkedin&logoColor=white)](https://www.linkedin.com/in/marcelomarquesmelo/)
[![twitter](https://img.shields.io/badge/twitter-1DA1F2?style=for-the-badge&logo=twitter&logoColor=white)](https://twitter.com/mmmarceleza)
[![YouTube](https://img.shields.io/badge/YouTube-%23FF0000.svg?style=for-the-badge&logo=YouTube&logoColor=white)](https://www.youtube.com/@whydevops)
[![YouTube](https://img.shields.io/badge/YouTube-%23FF0000.svg?style=for-the-badge&logo=YouTube&logoColor=white)](https://www.youtube.com/@marcelodevops)

---

# Prerequisites

- [GNU Stow](https://www.gnu.org/software/stow/)

---

# Installation

Clone this repository and run the stow script:

```bash
git clone https://github.com/mmmarceleza/dotfiles.git
cd dotfiles
./stow.sh
```

---

# Usage

```
./stow.sh [options] [package1 package2 ...]
```

**Options:**

| Option        | Description                      |
|---------------|----------------------------------|
| `--uninstall` | Remove symlinks instead of stow  |
| `--dry-run`   | Show actions without applying    |
| `--verbose`   | Show detailed output from stow   |
| `--help`      | Display help message             |

**Examples:**

```bash
./stow.sh                     # Apply all dotfiles
./stow.sh bash nvim           # Apply specific packages
./stow.sh --uninstall nvim    # Remove symlinks for nvim
./stow.sh --dry-run wezterm   # Preview changes without applying
./stow.sh --verbose           # Apply all with detailed output
```

---

# Available Packages

| Package   | Description                          |
|-----------|--------------------------------------|
| bash      | Bash shell configuration             |
| bin       | User scripts and binaries            |
| dolphin   | KDE Dolphin file manager             |
| espanso   | Text expander                        |
| git       | Git configuration                    |
| kanata    | Keyboard remapping                   |
| konsole   | KDE Konsole terminal                 |
| nvim      | Neovim configuration (Lua-based)     |
| shells    | Shared aliases and functions         |
| starship  | Starship prompt                      |
| tmux      | Tmux terminal multiplexer            |
| vim       | Vim configuration                    |
| wezterm   | WezTerm terminal emulator            |
| zellij    | Zellij terminal multiplexer          |
| zsh       | Zsh shell configuration              |

---

# References

- [Git Bare Repository - A Better Way To Manage Dotfiles](https://youtu.be/tBoLDpTWVOM)
- [Dotfiles: Best way to store in a bare git repository](https://www.atlassian.com/git/tutorials/dotfiles)
