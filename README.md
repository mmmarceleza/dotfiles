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

- [GNU Stow](https://www.gnu.org/software/stow/) >= 2.3.0
- [Git](https://git-scm.com/) (used for `--adopt` safety check)

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

| Option          | Description                                              |
|-----------------|----------------------------------------------------------|
| `--uninstall`   | Remove symlinks instead of stow                         |
| `--restow`      | Unstow then re-stow (cleans up stale symlinks)          |
| `--dry-run`     | Simulate actions without applying                        |
| `--verbose`     | Show detailed output from stow                           |
| `--adopt`       | Adopt existing files into package (with safety warning)  |
| `--backup`      | Back up conflicting files before stowing                 |
| `--folding`     | Allow directory symlinks (off by default)                |
| `--list`        | List all packages and their stow status                  |
| `--help`        | Display help message                                     |

**Examples:**

```bash
./stow.sh                        # Apply all dotfiles
./stow.sh bash nvim              # Apply specific packages
./stow.sh --uninstall nvim       # Remove symlinks for nvim
./stow.sh --restow bash          # Clean up stale symlinks
./stow.sh --backup bash          # Back up conflicts, then stow
./stow.sh --dry-run wezterm      # Preview changes without applying
./stow.sh --list                 # Show stowed/not-stowed status
```

> For detailed documentation including flowcharts, hook examples, and troubleshooting, see [docs/stow.md](docs/stow.md).

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
| zsh       | Zsh shell configuration              |

---

# References

- [Using GNU Stow to Manage Symbolic Links for Your Dotfiles](https://systemcrafters.net/managing-your-dotfiles/using-gnu-stow/)
- [How I manage my dotfiles using GNU Stow](https://tamerlan.dev/how-i-manage-my-dotfiles-using-gnu-stow/)
- [How To Easily Manage Your Dotfiles With GNU Stow](https://www.josean.com/posts/how-to-manage-dotfiles-with-gnu-stow)
- [GNU Stow Official Manual](https://www.gnu.org/software/stow/manual/stow.html)
