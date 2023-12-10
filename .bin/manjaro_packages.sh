#!/bin/bash

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
    # Check if the package is installed
    if pacman -Qi "$pkg" &> /dev/null; then
        # Package is installed, check if it needs an update
        installed_version=$(pacman -Qi "$pkg" | awk '/^Version/ {print $3}')
        available_version=$(pacman -Si "$pkg" | awk '/^Version/ {print $3}')
        
        if [[ $installed_version != "$available_version" ]]; then
            echo "Updating $pkg..."
            sudo pacman -Sy "$pkg" --noconfirm
        else
            echo "$pkg is already up-to-date."
        fi
    else
        # Package is not installed, install it
        echo "Installing $pkg..."
        sudo pacman -S "$pkg" --noconfirm || echo "Error installing $pkg. Continuing with the next package."
    fi
done

echo "Package installation/update complete."

