#!/bin/bash

#------------------------------------------------------------------------------
#                                  Functions
#------------------------------------------------------------------------------
# function to return a message and exit the program
function abort () {
  echo "$red$*$reset"
  exit 2
}

# function to print a colored message
function title () {
  echo "${yellow}$*$reset"
}

# function to install a specifc package with pacman
function require_package () {
  # check if receive one parameter
  if [ $# -ne 1 ]; then
    abort "${FUNCNAME[0]}: missing required parameters"
  fi
  # check if package is already installed
  if command -v "$1" &> /dev/null; then
    return
  fi
  echo "$1 is not installed. Installing $1..."
  pacman -S "$1" --noconfirm || abort "Error installing $1"
}

# Check if a unit exists, enable and start it if necessary
function enable_start_unit() {
  [ $# -eq 0 ] && return 1

  local unit_name=$1

  # Check if the unit exists
  if ! systemctl cat --no-pager "$unit_name" &>/dev/null ; then
    echo "Unit $unit_name does not exist on the system."
    return
  fi

  # Check if the unit is enabled
  if systemctl is-enabled --quiet "$unit_name"; then
    echo "Unit $unit_name is already enabled."
  else
    # Enable the unit if it's not already enabled
    echo "Enabling unit $unit_name..."
    sudo systemctl enable "$unit_name"
  fi

  # Check if the unit is running
  if systemctl is-active --quiet "$unit_name"; then
    echo "Unit $unit_name is already running."
    return
  fi

  # Start the unit if it's not already running
  echo "Starting unit $unit_name..."
  sudo systemctl start "$unit_name"
}

# add user to a group in /etc/group
function add_user_to_group () {
  [ $# -ne 1 ] && return 1

  local group=$1

  if ! grep -E "^$group:" /etc/group | grep "$1" &>/dev/null; then
    usermod -aG "$group" "$SCRIPT_USER"
  fi
}

#------------------------------------------------------------------------------
#                        Initial Validations and Variables
#------------------------------------------------------------------------------
# variables to put some color in the terminal
red=$(tput setaf 1)
yellow=$(tput setaf 3)
reset=$(tput sgr0)

# check if the script received only one parameter 
if [ $# -ne 1 ]; then
  abort "Enter only the user name"
fi

# check if the parameter is a user in the system
if ! id "$1" &>/dev/null; then
  abort "User $1 do not exists on the system."
fi

# set the variable user home path
SCRIPT_USER="$1"
eval USER_HOME=~"$1"

# check if the user home exists
if ! [ -d "$USER_HOME" ]; then
  abort "userdir not found: $1"
fi

#------------------------------------------------------------------------------
#                                  Main Script
#------------------------------------------------------------------------------
# List of packages to install from the main repositories
packages=(
    "actionlint"
    "authy"
    "base-devel"
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
    "gnu-netcat"
    "go-yq"
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
    "libreoffice-fresh"
    "libreoffice-fresh-pt-br"
    "lsd"
    "make"
    "meld"
    "mtr"
    "neovim"
    "nextcloud-client"
    "nodejs"
    "npm"
    "okd-client-bin"
    "openfortivpn"
    "paru-bin"
    "peek"
    "podman"
    "python-pip"
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
    "velero-bin"
    "vim"
    "virt-manager"
    "vscodium-bin"
    "whois"
    "wine"
    "wine-gecko"
    "wine-mono"
    "winetricks"
    "wireguard-tools"
    "xca"
    "xsel"
    "zellij"
    "zoxide"
)

# List of packages to install from Flathub (https://flathub.org/)
flatpak_packages=(
    "com.calibre_ebook.calibre"
    "com.github.johnfactotum.Foliate"
    "com.jgraph.drawio.desktop"
    "com.obsproject.Studio"
    "com.slack.Slack"
    "md.obsidian.Obsidian"
    "net.pcsx2.PCSX2"
    "org.audacityteam.Audacity"
    "org.jdownloader.JDownloader"
    "org.kde.kdenlive"
    "org.libretro.RetroArch"
    "org.videolan.VLC"
    "org.yuzu_emu.yuzu"
)

# List of appimage packages to install
appimage_packages=(
    "emulationstation-de:https://gitlab.com/es-de/emulationstation-de/-/package_files/100250157/download"
    # "url package-name"
)

# List of python packages to install
python_packages=(
  "giturlparse"
  "python-hcl2"
  )

# installing yay packages
title "Installing yay packages"
require_package yay
yay -Syu --noconfirm --needed "${packages[@]}" || abort "Error installing/updating packages"

# installing Flatpak packages
title "Installing flatpak packages"
require_package flatpak
flatpak install flathub -y "${flatpak_packages[@]}" || abort "Error installing flatpak package"

# Create the directory to install appimage packages, if it doesn't exist
title "Installing AppImage packages"
app_dir=$USER_HOME/Applications
mkdir -p "$app_dir" || abort "failed in creating of $app_dir"

for pkg in "${appimage_packages[@]}"; do
    # Split the package entry into URL and custom name
    url=${pkg#*:}
    name=${pkg%%:*}

    path="$app_dir/$name"

    if [ -e "$path" ]; then
        echo "$name is already installed."
    else
        echo "Installing $name from $url..."
        wget -O "$path" "$url" && chmod +x "$path" || abort "Error installing $name"
    fi
done

# installing python packges
title "Installing python packages"
pip install "${python_packages[@]}" --break-system-packages || abort "Error installing/updating packages"

# enabling some systemd units
title "Enabling some systemd units"
enable_start_unit libvirtd
enable_start_unit docker

# adding user on some linux groups
add_user_to_group docker
add_user_to_group libvirt

# installing vagrant plugins
title "Installing vagrant plugins"
PLUGIN_LIST=$(vagrant plugin list)
PLUGIN_LIST=${PLUGIN_LIST%% *}
if [ "$PLUGIN_LIST" = "vagrant-libvirt" ]; then
  echo "vagrant-libvirt plugin is already installed"
else
  echo "installing vagrant plugin"
  # vagrant plugin install vagrant-libvirt
fi

echo "Package installation/update complete."
