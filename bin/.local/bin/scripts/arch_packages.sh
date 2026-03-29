#!/usr/bin/env bash
#
# arch_packages.sh - Arch Linux workstation package installer
#
# Repository:  https://github.com/mmmarceleza/dotfiles
# Author:      Marcelo Marques Melo
#
# --------------------------------------------------------------
# Installs package sets for an Arch Linux workstation using
# official repositories, AUR (via yay), Flatpak, and user-scoped
# Python packages. Packages are grouped by segment so the
# environment can be installed selectively without editing the
# script.
#
# Usage:
#   ./arch_packages.sh [options]
#
# Examples:
#   ./arch_packages.sh --all
#   ./arch_packages.sh --list-segments
#   ./arch_packages.sh --segment base-cli,devops-k8s
#   ./arch_packages.sh --without gaming,media-creative
#   ./arch_packages.sh --segment desktop-apps --user marcelo
#
# Dependencies:
#   - pacman
#   - sudo
#   - systemd (for optional unit enablement)
#   - flatpak (only when Flatpak segments are selected)
#
# Notes:
#   - AUR packages are installed via yay, bootstrapped automatically
#   - Python extras use pip --user for the target user
#   - Docker/libvirt services are enabled only when their segment
#     is selected
#   - A log file is written to /tmp/arch_packages_<timestamp>.log
#
# --------------------------------------------------------------
# Changelog:
#
#   v1.0 2026-03-28, Marcelo Marques Melo:
#       - Initial Arch-focused version derived from manjaro_packages.sh
#       - Organized packages into selectable segments
#       - Uses yay as AUR helper (compiled from source to avoid libalpm breakage)
#       - Removed Snap entirely (migrated to Flatpak/AUR)
#       - Added segment selection (--all, --segment, --without)
#       - Added auto-detection of target user
#       - Added Flatpak remote bootstrapping
#       - Added conditional post-install (systemd, groups, vagrant)
#       - Added ERR trap with line number and command logging
#       - Added log file output via tee
#       - Added pre-flight checks (Arch detection, network, db lock)
#       - Added package existence validation before install
#       - Added retry wrapper for pacman/yay calls
#       - Added keyring refresh before system upgrade
#       - Added sudo credential caching with keep-alive
#
# License: MIT
# --------------------------------------------------------------

set -euo pipefail

# ###########################################################################
# #                     Error Handling and Logging                         #
# ###########################################################################

# --- ERR trap ---------------------------------------------------------------
# Catches the exact line and command that caused a failure. Invaluable for
# debugging long install runs.

trap 'echo "${red}Error on line $LINENO:${reset} $BASH_COMMAND" >&2' ERR

# --- Log file ---------------------------------------------------------------
# All stdout and stderr are duplicated to a timestamped log file via tee.
# The terminal still receives colored output in real time.

LOG_FILE="/tmp/arch_packages_$(date +%Y%m%d_%H%M%S).log"
exec > >(tee -a "$LOG_FILE") 2>&1

# ###########################################################################
# #                        Terminal Output Helpers                         #
# ###########################################################################

# --- Color definitions -----------------------------------------------------
# Wrapped with fallback so the script works in non-interactive environments
# (e.g. piped output, cron, CI).

red=$(tput setaf 1 2>/dev/null || true)
yellow=$(tput setaf 3 2>/dev/null || true)
green=$(tput setaf 2 2>/dev/null || true)
blue=$(tput setaf 4 2>/dev/null || true)
reset=$(tput sgr0 2>/dev/null || true)

# --- Print functions -------------------------------------------------------

# Print an error message to stderr and exit with code 1.
abort() {
  echo "${red}Error:${reset} $*" >&2
  exit 1
}

# Print a highlighted section title.
title() {
  echo
  echo "${yellow}==>${reset} $*"
}

# Print an informational status line.
info() {
  echo "${green}  ->${reset} $*"
}

# Print a warning message.
warn() {
  echo "${yellow}  Warning:${reset} $*"
}

# ###########################################################################
# #                         Usage and Validation                           #
# ###########################################################################

usage() {
  cat <<EOF
${blue}Usage:${reset}
  $(basename "$0") [options]

${blue}Options:${reset}
  --all                    Install all segments (default when no --segment)
  --list-segments          List available segments and exit
  --segment a,b,c          Install only the listed segments
  --without a,b,c          Exclude the listed segments from the selection
  --user USERNAME          Target user for user-scoped steps (default: auto-detect)
  --help                   Show this help message

${blue}Examples:${reset}
  $(basename "$0") --all
  $(basename "$0") --list-segments
  $(basename "$0") --segment base-cli,devops-k8s,desktop-apps
  $(basename "$0") --without gaming,media-creative
EOF
}

# Check that a command exists in PATH or abort.
require_command() {
  command -v "$1" >/dev/null 2>&1 || abort "Missing required command: $1"
}

# ###########################################################################
# #                           Segment Catalog                              #
# ###########################################################################
# Each segment groups packages by intent. The user can select or exclude
# segments at runtime to control exactly what gets installed.

declare -A SEGMENT_DESCRIPTIONS=(
  ["base-cli"]="Core terminal utilities and daily shell tooling"
  ["shell-tools"]="Extra shell, diff and file navigation tools"
  ["devops-k8s"]="Cloud, infra and Kubernetes tooling"
  ["containers-virt"]="Containers, virtualization and local lab tooling"
  ["network-security"]="VPN, networking and security scanners"
  ["desktop-apps"]="Desktop productivity and general-purpose GUI apps"
  ["media-creative"]="Creative, recording and media tooling"
  ["communication"]="Chat, notes and collaboration apps"
  ["gaming"]="Gaming, emulation and Wine stack"
  ["fonts"]="Nerd fonts and terminal fonts"
  ["python-user"]="Python CLI tools installed with pipx"
)

# Ordered list that defines the default installation sequence.
ALL_SEGMENTS=(
  "base-cli"
  "shell-tools"
  "devops-k8s"
  "containers-virt"
  "network-security"
  "desktop-apps"
  "media-creative"
  "communication"
  "gaming"
  "fonts"
  "python-user"
)

# ###########################################################################
# #                            Package Lists                               #
# ###########################################################################
# Packages are declared per source (pacman, AUR, flatpak, python) and mapped
# to segments using associative arrays. Each key is a segment name and the
# value is a space-separated list of package names.

# --- Official repositories (pacman) ----------------------------------------
# Preferred source. These integrate directly with pacman and receive updates
# through the standard Arch release process.

declare -A PACMAN_SEGMENTS=(
  ["base-cli"]="
    base-devel bash-completion bat btop chafa fd fzf jq lesspipe make
    mediainfo neovim nodejs npm perl-image-exiftool python-pip
    python-tabulate ripgrep rsync starship stow tailspin tldr tmux tree
    unzip vim yazi zellij zoxide
  "
  ["shell-tools"]="
    eza git-delta ipcalc kdiff3 lazygit ldns lsd meld openbsd-netcat rclone
    xclip xdotool xsel
  "
  ["devops-k8s"]="
    actionlint argocd cosign crane dive github-cli go go-yq helm k9s
    kubectx mariadb-clients terraform trivy vault
  "
  ["containers-virt"]="
    buildah docker docker-compose podman qemu-full virt-manager
  "
  ["network-security"]="
    mtr openfortivpn tailscale whois wireguard-tools
  "
  ["desktop-apps"]="
    flatpak keepassxc qbittorrent scrcpy syncthing wezterm xca
  "
  ["media-creative"]="
    inkscape peek
  "
  ["communication"]="
    discord telegram-desktop
  "
  ["gaming"]="
    lib32-mesa lib32-vulkan-intel steam wine wine-gecko wine-mono winetricks
  "
  ["fonts"]="
    ttf-hack-nerd ttf-jetbrains-mono-nerd
  "
)

# --- AUR (via yay) ---------------------------------------------------------
# Packages not available in the official repositories. The script bootstraps
# yay automatically when AUR packages are part of the active segments.

declare -A AUR_SEGMENTS=(
  ["devops-k8s"]="
    aws-cli-bin grype-bin hadolint-bin kind-bin kubepug-bin kubeval-bin
    okd-client-bin tfautomv-bin velero-bin
  "
  ["containers-virt"]="
    vagrant
  "
  ["network-security"]="
    cloudflare-warp-bin
  "
  ["desktop-apps"]="
    brave-bin espanso-x11-bin obsidian-bin visual-studio-code-bin
  "
)

# --- Flatpak ----------------------------------------------------------------
# GUI applications where the Flatpak packaging is lower friction or provides
# better sandboxing than the AUR alternative.

declare -A FLATPAK_SEGMENTS=(
  ["desktop-apps"]="
    com.google.Chrome
    com.github.jeromerobert.pdfarranger
    org.jdownloader.JDownloader
  "
  ["media-creative"]="
    com.jgraph.drawio.desktop
    com.obsproject.Studio
    org.audacityteam.Audacity
    org.kde.kdenlive
    org.videolan.VLC
  "
  ["communication"]="
    com.slack.Slack
    com.spotify.Client
    com.todoist.Todoist
  "
  ["gaming"]="
    net.pcsx2.PCSX2
  "
)

# --- User-scoped Python packages -------------------------------------------
# Installed with pipx so each tool gets its own virtual environment.
# This follows PEP 668 which blocks pip --user on externally-managed
# Python installations (like Arch's system Python).

declare -A PYTHON_SEGMENTS=(
  ["python-user"]="
    auto-editor
  "
)

# ###########################################################################
# #                          Argument Parsing                              #
# ###########################################################################

# --- State variables -------------------------------------------------------

TARGET_USER="${SUDO_USER:-${USER}}"
SELECTED_SEGMENTS=()
EXCLUDED_SEGMENTS=()
LIST_ONLY=false
FORCE_ALL=false

# --- Helper: split comma-separated values into an array --------------------

split_csv() {
  local input="$1"
  local -n output_ref="$2"
  local i

  output_ref=()
  IFS=',' read -r -a output_ref <<< "$input"

  # Trim whitespace from each entry
  for i in "${!output_ref[@]}"; do
    output_ref[i]="${output_ref[i]//[[:space:]]/}"
  done
}

# --- Helper: check if a segment name is valid ------------------------------

segment_exists() {
  local segment="$1"
  local candidate

  for candidate in "${ALL_SEGMENTS[@]}"; do
    [[ "$candidate" == "$segment" ]] && return 0
  done
  return 1
}

# --- Helper: abort on unknown segment names --------------------------------

validate_segments() {
  local segment

  for segment in "$@"; do
    [[ -z "$segment" ]] && abort "Empty segment name is not allowed"
    segment_exists "$segment" || abort "Unknown segment: $segment (use --list-segments to see valid names)"
  done
}

# --- Helper: print segment catalog -----------------------------------------

list_segments() {
  local segment

  echo "${blue}Available segments:${reset}"
  echo
  for segment in "${ALL_SEGMENTS[@]}"; do
    printf "  %-24s %s\n" "$segment" "${SEGMENT_DESCRIPTIONS[$segment]}"
  done
}

# --- Parse command-line arguments ------------------------------------------

while [[ $# -gt 0 ]]; do
  case "$1" in
    --list-segments)
      LIST_ONLY=true
      shift
      ;;
    --all)
      FORCE_ALL=true
      shift
      ;;
    --segment)
      [[ $# -ge 2 ]] || abort "Missing value for --segment"
      split_csv "$2" SELECTED_SEGMENTS
      shift 2
      ;;
    --without)
      [[ $# -ge 2 ]] || abort "Missing value for --without"
      split_csv "$2" EXCLUDED_SEGMENTS
      shift 2
      ;;
    --user)
      [[ $# -ge 2 ]] || abort "Missing value for --user"
      TARGET_USER="$2"
      shift 2
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    *)
      abort "Unknown option: $1"
      ;;
  esac
done

# --- Validate parsed input -------------------------------------------------

validate_segments "${SELECTED_SEGMENTS[@]}"
validate_segments "${EXCLUDED_SEGMENTS[@]}"

if ! id "$TARGET_USER" >/dev/null 2>&1; then
  abort "User does not exist: $TARGET_USER"
fi

TARGET_HOME=$(getent passwd "$TARGET_USER" | cut -d: -f6)
[[ -n "$TARGET_HOME" && -d "$TARGET_HOME" ]] || abort "Home directory not found for user: $TARGET_USER"

# Handle --list-segments early exit
if $LIST_ONLY; then
  list_segments
  exit 0
fi

# --- Resolve active segments ------------------------------------------------
# If --segment was provided, use only those. Otherwise use all segments.
# Then apply --without exclusions.

if $FORCE_ALL || [[ ${#SELECTED_SEGMENTS[@]} -eq 0 ]]; then
  ACTIVE_SEGMENTS=("${ALL_SEGMENTS[@]}")
else
  ACTIVE_SEGMENTS=("${SELECTED_SEGMENTS[@]}")
fi

if [[ ${#EXCLUDED_SEGMENTS[@]} -gt 0 ]]; then
  filtered=()
  for segment in "${ACTIVE_SEGMENTS[@]}"; do
    skip=false
    for excluded in "${EXCLUDED_SEGMENTS[@]}"; do
      if [[ "$segment" == "$excluded" ]]; then
        skip=true
        break
      fi
    done
    $skip || filtered+=("$segment")
  done
  ACTIVE_SEGMENTS=("${filtered[@]}")
fi

[[ ${#ACTIVE_SEGMENTS[@]} -gt 0 ]] || abort "No segments selected after applying filters"

# ###########################################################################
# #                      Package Collection Helpers                        #
# ###########################################################################

# Check if a given segment is in the active set.
contains_segment() {
  local wanted="$1"
  local segment

  for segment in "${ACTIVE_SEGMENTS[@]}"; do
    [[ "$segment" == "$wanted" ]] && return 0
  done
  return 1
}

# Collect packages from a source map across all active segments,
# deduplicating repeated entries.
collect_packages() {
  local source_name="$1"
  local segment package package_blob
  declare -A seen=()
  local -a collected=()

  for segment in "${ACTIVE_SEGMENTS[@]}"; do
    case "$source_name" in
      pacman)  package_blob="${PACMAN_SEGMENTS[$segment]:-}" ;;
      aur)     package_blob="${AUR_SEGMENTS[$segment]:-}" ;;
      flatpak) package_blob="${FLATPAK_SEGMENTS[$segment]:-}" ;;
      python)  package_blob="${PYTHON_SEGMENTS[$segment]:-}" ;;
      *)       abort "Unknown package source: $source_name" ;;
    esac

    # Word-split the blob into individual package names
    for package in $package_blob; do
      if [[ -n "$package" && -z "${seen[$package]:-}" ]]; then
        seen[$package]=1
        collected+=("$package")
      fi
    done
  done

  [[ ${#collected[@]} -gt 0 ]] && printf '%s\n' "${collected[@]}"
}

# Run a command as the target user, preserving HOME.
run_as_target_user() {
  if [[ "$(id -un)" == "$TARGET_USER" ]]; then
    HOME="$TARGET_HOME" "$@"
  else
    sudo -H -u "$TARGET_USER" "$@"
  fi
}

# ###########################################################################
# #                          Pre-flight Checks                             #
# ###########################################################################
# Verify the environment before touching anything. Each check is a small
# function so failures are easy to trace in the log.

# --- Arch Linux detection ---------------------------------------------------
# Prevent running on Ubuntu, Fedora, etc. where pacman does not exist or
# behaves differently.

check_root() {
  if [[ "$(id -u)" -ne 0 ]]; then
    abort "This script must be run as root (use sudo)"
  fi
}

check_arch_linux() {
  if [[ ! -f /etc/os-release ]]; then
    abort "Cannot detect OS: /etc/os-release not found"
  fi

  local os_id
  # shellcheck source=/dev/null
  os_id=$(. /etc/os-release && echo "${ID:-}")

  if [[ "$os_id" != "arch" ]]; then
    abort "This script is designed for Arch Linux (detected: ${os_id:-unknown})"
  fi
}

# --- Network connectivity --------------------------------------------------
# A package install without network is guaranteed to fail. Catch it early
# with a clear message instead of cryptic 404 errors from pacman.

check_network() {
  if ! ping -c 1 -W 5 archlinux.org >/dev/null 2>&1; then
    abort "No network connectivity (cannot reach archlinux.org)"
  fi
}

# --- Pacman database lock ---------------------------------------------------
# A leftover lock file from a previous crashed pacman session blocks all
# package operations. Detect it and tell the user how to fix it.

check_pacman_lock() {
  if [[ -f /var/lib/pacman/db.lck ]]; then
    abort "Pacman database is locked (/var/lib/pacman/db.lck exists). Another pacman instance may be running, or a previous run crashed. Remove the lock file manually if no other pacman process is active: sudo rm /var/lib/pacman/db.lck"
  fi
}

# --- Sudo credentials ------------------------------------------------------
# Cache sudo credentials at the start and keep them alive in the background
# so the user is not prompted again during a long install run.

SUDO_KEEPALIVE_PID=""
SUDOERS_TMPFILE=""

start_sudo_keepalive() {
  # Prompt for password once
  sudo -v || abort "Failed to obtain sudo credentials"

  # Grant the target user temporary passwordless sudo so that AUR helpers
  # (yay, makepkg) can call pacman without a terminal for password input.
  SUDOERS_TMPFILE="/etc/sudoers.d/zzz-arch-packages-tmp"
  echo "$TARGET_USER ALL=(ALL) NOPASSWD: ALL" | sudo tee "$SUDOERS_TMPFILE" > /dev/null
  sudo chmod 440 "$SUDOERS_TMPFILE"

  # Background loop that refreshes the sudo timestamp every 50 seconds
  while true; do
    sudo -n true 2>/dev/null
    sleep 50
  done &
  SUDO_KEEPALIVE_PID=$!

  # Kill the keep-alive process and remove temporary sudoers when the script exits
  trap 'kill "$SUDO_KEEPALIVE_PID" 2>/dev/null || true; sudo rm -f "$SUDOERS_TMPFILE" 2>/dev/null || true' EXIT
}

# ###########################################################################
# #                    Install Source Bootstrapping                         #
# ###########################################################################

# --- Multilib repository ----------------------------------------------------
# Steam and some 32-bit Wine libraries live in the multilib repository,
# which is disabled by default on a fresh Arch install.

ensure_multilib() {
  if grep -qE '^\[multilib\]' /etc/pacman.conf; then
    return
  fi

  title "Enabling multilib repository"

  if grep -qE '^#\[multilib\]' /etc/pacman.conf; then
    # Section exists but is commented out (default Arch install)
    sudo sed -i '/^#\[multilib\]/,/^#Include/ s/^#//' /etc/pacman.conf
  else
    # Section is completely missing (e.g. minimal install)
    printf '\n[multilib]\nInclude = /etc/pacman.d/mirrorlist\n' \
      | sudo tee -a /etc/pacman.conf > /dev/null
  fi

  # Full -Syu instead of -Sy to avoid partial upgrades, which are
  # unsupported on Arch and can break the system.
  sudo pacman -Syu --noconfirm
}

# --- Keyring refresh --------------------------------------------------------
# On systems that have not been updated for a while the keyring may be stale,
# causing PGP signature verification failures during package installation.
# Refreshing archlinux-keyring first prevents this class of errors.

refresh_keyring() {
  title "Refreshing pacman keyring"
  sudo pacman -Sy --needed --noconfirm archlinux-keyring
}

# --- Flatpak remote ---------------------------------------------------------
# Ensure Flathub is configured before attempting any Flatpak installs.

ensure_flatpak_remote() {
  require_command flatpak

  if ! flatpak remote-list --columns=name | grep -qx 'flathub'; then
    title "Adding Flathub remote"
    sudo flatpak remote-add --if-not-exists flathub \
      https://flathub.org/repo/flathub.flatpakrepo
  fi
}

# --- Yay (AUR helper) ------------------------------------------------------
# Install yay only when AUR packages are part of the active segments.
# Compiled from source (not yay-bin) to link against the current libalpm.
# Precompiled -bin packages break when pacman bumps the libalpm soname.

ensure_yay() {
  if command -v yay >/dev/null 2>&1; then
    return
  fi

  title "Bootstrapping yay"
  sudo pacman -S --needed --noconfirm base-devel git go

  local temp_dir
  temp_dir=$(run_as_target_user mktemp -d /tmp/yay-bootstrap.XXXXXX)
  # Clean up the temp directory when the function returns
  trap 'rm -rf "$temp_dir"' RETURN

  run_as_target_user git clone https://aur.archlinux.org/yay.git "$temp_dir/yay"
  run_as_target_user bash -lc "cd '$temp_dir/yay' && makepkg -s --noconfirm"
  sudo pacman -U --noconfirm "$temp_dir"/yay/yay-*.pkg.tar.*
}

# ###########################################################################
# #                    Package Validation and Retry                        #
# ###########################################################################

# --- Validate pacman packages -----------------------------------------------
# Check that every package in the list exists in the sync database before
# attempting to install. This catches typos and removed packages early,
# before pacman starts downloading anything.

validate_pacman_packages() {
  local -a packages=("$@")
  local -a missing=()
  local pkg

  for pkg in "${packages[@]}"; do
    if ! pacman -Si "$pkg" >/dev/null 2>&1 \
      && ! pacman -Sg "$pkg" >/dev/null 2>&1; then
      missing+=("$pkg")
    fi
  done

  if [[ ${#missing[@]} -gt 0 ]]; then
    warn "The following pacman packages were not found in the sync database:"
    for pkg in "${missing[@]}"; do
      echo "    $pkg"
    done
    abort "Fix the package names above before continuing"
  fi
}

# --- Retry wrapper ----------------------------------------------------------
# Retries a command up to MAX_RETRIES times with a short delay between
# attempts. Useful for pacman/yay calls that can fail due to transient
# network issues or overloaded mirrors.

MAX_RETRIES=3
RETRY_DELAY=5

retry() {
  local attempt=1
  local rc=0

  while true; do
    "$@" && return 0 || rc=$?

    if [[ $attempt -ge $MAX_RETRIES ]]; then
      warn "Command failed after $MAX_RETRIES attempts: $*"
      return $rc
    fi

    warn "Attempt $attempt/$MAX_RETRIES failed (exit $rc), retrying in ${RETRY_DELAY}s..."
    sleep "$RETRY_DELAY"
    ((attempt++))
  done
}

# ###########################################################################
# #                     Post-install Integration                           #
# ###########################################################################
# These steps only run when the relevant segment is active.

# --- Systemd units ----------------------------------------------------------
# Enable a systemd unit if it exists on the current machine.

enable_unit_if_available() {
  local unit_name="$1"

  if ! systemctl cat --no-pager "$unit_name" >/dev/null 2>&1; then
    info "Skipping missing unit: $unit_name"
    return
  fi

  if systemctl is-enabled --quiet "$unit_name" \
    && systemctl is-active --quiet "$unit_name"; then
    info "$unit_name is already enabled and running"
    return
  fi

  title "Enabling and starting $unit_name"
  sudo systemctl enable --now "$unit_name"
}

# --- User groups ------------------------------------------------------------
# Add the target user to a supplementary group if not already a member.

add_user_to_group() {
  local group_name="$1"

  if id -nG "$TARGET_USER" | tr ' ' '\n' | grep -qx "$group_name"; then
    info "$TARGET_USER is already in group $group_name"
    return
  fi

  title "Adding $TARGET_USER to group $group_name"
  sudo usermod -aG "$group_name" "$TARGET_USER"
}

# --- Vagrant plugin ---------------------------------------------------------
# Install the vagrant-libvirt plugin if vagrant is available.

install_vagrant_plugin() {
  command -v vagrant >/dev/null 2>&1 || return

  if run_as_target_user vagrant plugin list | grep -q '^vagrant-libvirt '; then
    info "vagrant-libvirt plugin is already installed"
    return
  fi

  title "Installing vagrant-libvirt plugin"
  run_as_target_user vagrant plugin install vagrant-libvirt
}

# ###########################################################################
# #                        Main Execution Flow                             #
# ###########################################################################

main() {
  require_command bash
  require_command sudo
  require_command pacman

  info "Log file: $LOG_FILE"

  # --- Pre-flight checks ----------------------------------------------------

  title "Running pre-flight checks"
  check_root
  info "Running as root"
  check_arch_linux
  info "Arch Linux detected"
  check_network
  info "Network connectivity OK"
  check_pacman_lock
  info "Pacman database is not locked"

  # --- Cache sudo credentials ------------------------------------------------

  start_sudo_keepalive

  # --- Show selected segments -----------------------------------------------

  title "Selected segments"
  for segment in "${ACTIVE_SEGMENTS[@]}"; do
    info "$segment"
  done

  # --- Collect packages from all sources ------------------------------------

  mapfile -t pacman_packages < <(collect_packages pacman)
  mapfile -t aur_packages    < <(collect_packages aur)
  mapfile -t flatpak_packages < <(collect_packages flatpak)
  mapfile -t python_packages < <(collect_packages python)

  # --- Enable multilib if gaming segment is active ---------------------------
  # Steam and 32-bit Wine libraries require the multilib repository.

  if contains_segment "gaming"; then
    ensure_multilib
  fi

  # --- Refresh keyring -------------------------------------------------------
  # Prevents PGP signature failures on systems that have not been updated
  # recently. Uses -Sy (partial sync) intentionally: the full -Syu follows
  # immediately in the pacman install step, so the window is safe.

  refresh_keyring

  # --- Validate pacman packages before installing ----------------------------
  # Catches typos and removed packages before pacman starts downloading.

  if [[ ${#pacman_packages[@]} -gt 0 ]]; then
    title "Validating ${#pacman_packages[@]} pacman packages"
    validate_pacman_packages "${pacman_packages[@]}"
    info "All pacman packages found in sync database"
  fi

  # --- Install pacman packages ----------------------------------------------

  if [[ ${#pacman_packages[@]} -gt 0 ]]; then
    title "Installing ${#pacman_packages[@]} pacman packages"
    retry sudo pacman -Syu --noconfirm --needed "${pacman_packages[@]}"
  fi

  # --- Install AUR packages -------------------------------------------------

  if [[ ${#aur_packages[@]} -gt 0 ]]; then
    ensure_yay
    title "Installing ${#aur_packages[@]} AUR packages"
    retry run_as_target_user yay -Syu --noconfirm --needed "${aur_packages[@]}"
  fi

  # --- Install Flatpak packages ---------------------------------------------

  if [[ ${#flatpak_packages[@]} -gt 0 ]]; then
    ensure_flatpak_remote
    title "Installing ${#flatpak_packages[@]} Flatpak packages"
    retry sudo flatpak install -y flathub "${flatpak_packages[@]}"
  fi

  # --- Install Python packages (user-scoped via pipx) -----------------------

  if [[ ${#python_packages[@]} -gt 0 ]]; then
    sudo pacman -S --needed --noconfirm python-pipx
    title "Installing ${#python_packages[@]} Python packages for $TARGET_USER"
    local pkg
    for pkg in "${python_packages[@]}"; do
      info "pipx install $pkg"
      retry run_as_target_user pipx install --force "$pkg"
    done
  fi

  # --- Post-install: containers and virtualization --------------------------

  if contains_segment "containers-virt"; then
    title "Post-install: containers and virtualization"
    enable_unit_if_available docker.service
    enable_unit_if_available libvirtd.service
    add_user_to_group docker
    add_user_to_group libvirt
    install_vagrant_plugin
  fi

  # --- Done -----------------------------------------------------------------

  title "Done"
  echo "Package installation complete for user ${blue}${TARGET_USER}${reset}."
  info "Full log saved to: $LOG_FILE"
}

main "$@"
