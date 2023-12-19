#!/bin/bash

# Check if yay is installed
if ! command -v yay &> /dev/null; then
    echo "yay is not installed. Installing yay..."
    sudo pacman -S yay --noconfirm || { echo "Error installing yay. Exiting."; exit 1; }
fi

# Check if flatpak is installed
if ! command -v flatpak &> /dev/null; then
    echo "Flatpak is not installed. Installing flatpak..."
    sudo pacman -S flatpak --noconfirm || { echo "Error installing flatpak. Exiting."; exit 1; }
fi

# List of packages to install from the main repositories
packages=("actionlint"
    "authy"
    "bash-completion"
    "bat"
    "brave-browser"
    "btop"
    "discord"
    "dive"
    "docker"
    "docker-compose"
    "fd"
    "fzf"
    "git-delta"
    "github-cli"
    "go"
    "google-chrome"
    "hadolint-bin"
    "helm"
    "inkscape"
    "ipcalc"
    "jq"
    "k9s"
    "kdiff3"
    "keepassxc"
    "kind-bin"
    "kubectl"
    "kubectx"
    "kustomize"
    "lazygit"
    "lsd"
    "make"
    "meld"
    "mtr"
    "neovim"
    "nextcloud-client"
    "nodejs"
    "npm"
    "okd-client-bin"
    "paru-bin"
    "peek"
    "podman"
    "qbittorrent"
    "qemu-full"
    "rclone"
    "ripgrep"
    "rsync"
    "scrcpy"
    "starship"
    "steam"
    "stow"
    "telegram-desktop"
    "terraform"
    "thunderbird"
    "thunderbird-i18n-en-us"
    "thunderbird-i18n-pt-br"
    "tmux"
    "tree"
    "trivy"
    "ttf-hack-nerd"
    "unzip"
    "vagrant"
    "vim"
    "virt-manager"
    "vscodium-bin"
    "whois"
    "wireguard-tools"
    "xsel"
    "zellij"
    "zoxide")

flatpak_packages=("com.jgraph.drawio.desktop"
    "com.obsproject.Studio"
    "com.slack.Slack"
    "md.obsidian.Obsidian"
    "net.pcsx2.PCSX2"
    "org.audacityteam.Audacity"
    "org.jdownloader.JDownloader"
    "org.kde.kdenlive"
    "org.libretro.RetroArch"
    "org.videolan.VLC"
    "org.yuzu_emu.yuzu")

for pkg in "${packages[@]}"; do
    # Check if the package is in the official repositories
    if yay -Qi "$pkg" &> /dev/null; then
        # Package is in the official repositories, check if it needs an update
        installed_version=$(yay -Qi "$pkg" | awk '/^Version/ {print $3}')
        available_version=$(yay -Si "$pkg" | awk '/^Version/ {print $3}')
        
        if [[ "$installed_version" != "$available_version" ]]; then
            echo "Updating $pkg..."
            yay -Syu --noconfirm --needed "$pkg"
        else
            echo "$pkg is already up-to-date."
        fi
    else
        # Package is not in the official repositories, use yay to install/update from AUR
        echo "Installing/Updating $pkg from AUR..."
        yay -Syu --noconfirm --needed "$pkg" || { echo "Error installing/updating $pkg. Exiting."; exit 1; }
    fi
done

# Install Flatpak packages
for pkg in "${flatpak_packages[@]}"; do
    if flatpak list --app "$pkg" &> /dev/null; then
        echo "$pkg is already installed."
    else
        echo "Installing $pkg from Flathub..."
        flatpak install flathub "$pkg" -y || { echo "Error installing $pkg. Exiting."; exit 1; }
    fi
done

echo "Package installation/update complete."
