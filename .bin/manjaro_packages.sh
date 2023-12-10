#!/bin/bash

# Check if yay is installed
if ! command -v yay &> /dev/null; then
    echo "yay is not installed. Installing yay..."
    sudo pacman -S yay --noconfirm || { echo "Error installing yay. Exiting."; exit 1; }
fi

# List of packages to install
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
    "flatpak"
    "fzf"
    "git-delta"
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
    "xsel"
    "zellij"
    "zoxide")

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

echo "Package installation/update complete."
