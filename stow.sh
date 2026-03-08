#!/usr/bin/env bash
#
# stow.sh - GNU Stow wrapper for dotfiles management
#
# Repository:  https://github.com/mmmarceleza/dotfiles
# Author:      Marcelo Marques Melo
#
# --------------------------------------------------------------
# A wrapper around GNU Stow that simplifies managing dotfiles
# by providing auto-discovery of packages, conflict backup,
# post-stow hooks, colored output, and safety checks.
#
# Each top-level directory in this repository is a stow package.
# Running this script creates symlinks from $HOME to the files
# inside each package, mirroring the directory structure.
#
# Usage:
#   ./stow.sh [options] [package1 package2 ...]
#
# Examples:
#   ./stow.sh                      # Stow all packages
#   ./stow.sh bash nvim            # Stow specific packages
#   ./stow.sh --uninstall nvim     # Remove symlinks for nvim
#   ./stow.sh --backup bash        # Back up conflicts, then stow
#   ./stow.sh --list               # Show package status
#
# Dependencies:
#   - GNU Stow >= 2.3.0
#   - git (for --adopt safety check)
#
# Full documentation: docs/stow.md
#
# --------------------------------------------------------------
# Changelog:
#
#   v1.0 2025-06-13, Marcelo Marques Melo:
#       - Initial version with stow/unstow, dry-run, verbose,
#         adopt, auto-discovery, and colored output
#
#   v2.0 2026-03-01, Marcelo Marques Melo:
#       - Added --no-folding by default (--folding to opt out)
#       - Added --restow action
#       - Added --adopt safety warning for uncommitted changes
#       - Added --list with stowed/partial/not-stowed status
#       - Added --backup for conflict detection and auto-backup
#       - Added post-stow/post-unstow hooks via .stow-hooks/
#       - Added stow version check (>= 2.3.0)
#
# License: MIT
# --------------------------------------------------------------

set -euo pipefail

# ----------------------------
# Color definitions
# ----------------------------
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
BLUE="\033[1;34m"
RESET="\033[0m"

# Directories that are not stow packages
IGNORE_DIRS=(".git" ".github" ".claude" "docs")

# ----------------------------
# Print usage instructions and exit with the given code (default: 0)
# ----------------------------
usage() {
  local exit_code="${1:-0}"
  echo -e "${BLUE}Usage:${RESET}"
  echo "  $(basename "$0") [options] [package1 package2 ...]"
  echo
  echo -e "${BLUE}Options:${RESET}"
  echo "  --uninstall      Unlink instead of stow"
  echo "  --restow         Unstow then re-stow (cleans up stale symlinks)"
  echo "  --dry-run        Simulate actions using stow's --simulate flag"
  echo "  --verbose        Show verbose output from stow"
  echo "  --adopt          Adopt existing files into package directory"
  echo "  --backup         Back up conflicting files before stowing"
  echo "  --folding        Allow stow to symlink entire directories (off by default)"
  echo "  --list           List all packages and their stow status"
  echo "  --help           Show this help message"
  echo
  echo -e "${BLUE}Hooks:${RESET}"
  echo "  Place executable scripts in <package>/.stow-hooks/"
  echo "  Supported hooks: post-stow, post-unstow"
  echo
  echo -e "${BLUE}Examples:${RESET}"
  echo "  $(basename "$0")                    # Apply all dotfiles"
  echo "  $(basename "$0") bash nvim          # Apply specific packages"
  echo "  $(basename "$0") --uninstall nvim"
  echo "  $(basename "$0") --restow bash      # Clean up stale symlinks"
  echo "  $(basename "$0") --dry-run wezterm"
  echo "  $(basename "$0") --verbose"
  exit "$exit_code"
}

# ----------------------------
# Check if 'stow' is installed
# ----------------------------
if ! command -v stow >/dev/null 2>&1; then
  echo -e "${RED}Error: 'stow' is not installed or not in PATH.${RESET}" >&2
  exit 1
fi

STOW_VERSION="$(stow --version 2>&1 | grep -oP '[\d.]+')"
STOW_MIN_VERSION="2.3.0"
if [[ "$(printf '%s\n' "$STOW_MIN_VERSION" "$STOW_VERSION" | sort -V | head -1)" != "$STOW_MIN_VERSION" ]]; then
  echo -e "${RED}Error: stow >= $STOW_MIN_VERSION required (found $STOW_VERSION).${RESET}" >&2
  exit 1
fi

# ----------------------------
# Check if a directory name should be ignored (not a stow package)
# ----------------------------
is_ignored() {
  local name="$1"
  for ignored in "${IGNORE_DIRS[@]}"; do
    [[ "$name" == "$ignored" ]] && return 0
  done
  return 1
}

# ----------------------------
# Check if a package is stowed by examining its symlinks in $HOME
# Returns: 0 = fully stowed, 1 = not stowed, 2 = partially stowed
# ----------------------------
check_stow_status() {
  local pkg="$1"
  local pkg_dir="$DOTFILES_DIR/$pkg"
  local total=0
  local linked=0

  while IFS= read -r -d '' file; do
    local rel="${file#"$pkg_dir"/}"
    local target="$HOME/$rel"
    ((total++)) || true
    if [[ -L "$target" ]]; then
      local link_dest
      link_dest="$(readlink -f "$target" 2>/dev/null)" || continue
      if [[ "$link_dest" == "$pkg_dir/"* ]]; then
        ((linked++)) || true
      fi
    fi
  done < <(find "$pkg_dir" -path '*/.stow-hooks' -prune -o -type f -print0)

  if [[ $total -eq 0 || $linked -eq 0 ]]; then
    return 1
  elif [[ $linked -eq $total ]]; then
    return 0
  else
    return 2
  fi
}

# ----------------------------
# List all available packages with their stow status
# ----------------------------
list_packages() {
  for d in "$DOTFILES_DIR"/*/; do
    [[ ! -d "$d" ]] && continue
    local name
    name="$(basename "${d%/}")"
    is_ignored "$name" && continue

    check_stow_status "$name" && rc=0 || rc=$?
    case $rc in
      0) echo -e "  ${GREEN}[stowed]${RESET}      $name" ;;
      2) echo -e "  ${YELLOW}[partial]${RESET}     $name" ;;
      *) echo -e "  [not stowed]  $name" ;;
    esac
  done
}

# ----------------------------
# Back up files that would conflict with stowing a package
# ----------------------------
backup_conflicts() {
  local pkg="$1"
  local sim_cmd=(stow --simulate --target="$TARGET_DIR" --dir="$DOTFILES_DIR" --stow)
  $NO_FOLDING && sim_cmd+=("--no-folding")
  sim_cmd+=("$pkg")

  local sim_output
  sim_output="$("${sim_cmd[@]}" 2>&1)" || true

  local conflicts
  conflicts="$(echo "$sim_output" | grep -oP '(?<=over existing target )\S+(?= since neither)|(?<=existing target is not owned by stow: )\S+' || true)"
  [[ -z "$conflicts" ]] && return 0

  local backup_dir
  backup_dir="$DOTFILES_DIR/.backups/$(date +%Y-%m-%d_%H%M%S)"
  echo -e "${YELLOW}Backing up conflicting files to ${backup_dir##"$DOTFILES_DIR"/}${RESET}"

  while IFS= read -r file; do
    local src="$TARGET_DIR/$file"
    local dest="$backup_dir/$file"
    mkdir -p "$(dirname "$dest")"
    mv "$src" "$dest"
    echo "  $file"
  done <<< "$conflicts"
}

# ----------------------------
# Run a hook script for a package if it exists
# ----------------------------
run_hook() {
  local pkg="$1"
  local hook="$2"
  local hook_path="$DOTFILES_DIR/$pkg/.stow-hooks/$hook"

  if [[ -x "$hook_path" ]]; then
    echo -e "${BLUE}Running $hook hook for $pkg${RESET}"
    if ! "$hook_path"; then
      echo -e "${YELLOW}Warning: $hook hook for $pkg failed${RESET}"
    fi
  fi
}

# ----------------------------
# Initialization
# ----------------------------
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="$HOME"
ACTION="--stow"
DRY_RUN=false
VERBOSE=false
ADOPT=false
BACKUP=false
NO_FOLDING=true
STOW_DIRS=()

# ----------------------------
# Parse command-line arguments
# ----------------------------
while [[ $# -gt 0 ]]; do
  case "$1" in
    --uninstall)
      ACTION="--delete"
      shift
      ;;
    --restow)
      ACTION="--restow"
      shift
      ;;
    --dry-run)
      DRY_RUN=true
      shift
      ;;
    --verbose)
      VERBOSE=true
      shift
      ;;
    --adopt)
      ADOPT=true
      shift
      ;;
    --backup)
      BACKUP=true
      shift
      ;;
    --folding)
      NO_FOLDING=false
      shift
      ;;
    --list)
      list_packages
      exit 0
      ;;
    --help)
      usage 0
      ;;
    -*)
      echo -e "${RED}Unknown option: $1${RESET}" >&2
      echo >&2
      usage 1
      ;;
    *)
      STOW_DIRS+=("$1")
      shift
      ;;
  esac
done

# ----------------------------
# Warn if --adopt is used with uncommitted changes
# ----------------------------
if $ADOPT && ! $DRY_RUN; then
  if ! git -C "$DOTFILES_DIR" diff --quiet 2>/dev/null || \
     ! git -C "$DOTFILES_DIR" diff --cached --quiet 2>/dev/null; then
    echo -e "${RED}Warning: --adopt will overwrite repo files with versions from \$HOME.${RESET}"
    echo -e "${RED}You have uncommitted changes that could be lost.${RESET}"
    read -rp "Continue? [y/N] " confirm
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
      echo "Aborted."
      exit 1
    fi
  fi
fi

# ----------------------------
# If no packages specified, discover all package directories
# ----------------------------
if [[ ${#STOW_DIRS[@]} -eq 0 ]]; then
  for d in "$DOTFILES_DIR"/*/; do
    [[ ! -d "$d" ]] && continue
    name="$(basename "${d%/}")"
    is_ignored "$name" && continue
    STOW_DIRS+=("$name")
  done
fi

if [[ ${#STOW_DIRS[@]} -eq 0 ]]; then
  echo -e "${YELLOW}No packages found in $DOTFILES_DIR${RESET}"
  exit 0
fi

# ----------------------------
# Validate that each package directory exists
# ----------------------------
for dir in "${STOW_DIRS[@]}"; do
  if [[ ! -d "$DOTFILES_DIR/$dir" ]]; then
    echo -e "${RED}Error: Package directory '$dir' does not exist in $DOTFILES_DIR${RESET}" >&2
    exit 1
  fi
done

# ----------------------------
# Print summary
# ----------------------------
echo -e "${BLUE}Dotfiles directory:${RESET} $DOTFILES_DIR"
echo -e "${BLUE}Target directory:${RESET}   $TARGET_DIR"
echo -e "${BLUE}Action:${RESET}             $ACTION"
$DRY_RUN && echo -e "${YELLOW}Dry-run enabled (simulating with stow --simulate)${RESET}"
$VERBOSE && echo -e "${BLUE}Verbose output:${RESET}     enabled"
$ADOPT   && echo -e "${YELLOW}Adopt mode enabled${RESET}"
echo -e "${BLUE}Packages:${RESET}           ${STOW_DIRS[*]}"
echo

# ----------------------------
# Apply stow/uninstall for each package
# ----------------------------
success_count=0
fail_count=0

for dir in "${STOW_DIRS[@]}"; do
  echo -e "${GREEN}Processing: $dir${RESET}"

  # Back up conflicting files before stowing
  if $BACKUP && ! $DRY_RUN && [[ "$ACTION" == "--stow" ]]; then
    backup_conflicts "$dir"
  fi

  CMD=(stow --target="$TARGET_DIR" --dir="$DOTFILES_DIR" "$ACTION")
  $NO_FOLDING && CMD+=("--no-folding")
  $DRY_RUN    && CMD+=("--simulate")
  $VERBOSE    && CMD+=("--verbose")
  $ADOPT      && CMD+=("--adopt")
  CMD+=("--ignore=\\.stow-hooks")
  CMD+=("$dir")

  # Stow sends all output (including --simulate warnings) to stderr.
  # Merge stderr into stdout so we can capture and display it properly.
  OUTPUT="$("${CMD[@]}" 2>&1)" && rc=0 || rc=$?

  # Filter out the simulation mode warning (not an error)
  FILTERED="${OUTPUT/WARNING: in simulation mode so not modifying filesystem./}"
  FILTERED="$(echo "$FILTERED" | sed '/^$/d')"

  if [[ $rc -ne 0 && -n "$FILTERED" ]]; then
    echo -e "${RED}Error processing package: $dir${RESET}"
    echo "$FILTERED"
    ((fail_count++)) || true
  else
    [[ -n "$FILTERED" ]] && echo "$FILTERED"
    ((success_count++)) || true

    # Run post-action hooks (skip during dry-run)
    if ! $DRY_RUN; then
      case "$ACTION" in
        --stow|--restow) run_hook "$dir" "post-stow" ;;
        --delete)         run_hook "$dir" "post-unstow" ;;
      esac
    fi
  fi
done

# ----------------------------
# Final summary
# ----------------------------
echo
case "$ACTION" in
  --stow)    action_label="linked" ;;
  --delete)  action_label="unlinked" ;;
  --restow)  action_label="restowed" ;;
esac

if [[ $fail_count -eq 0 ]]; then
  echo -e "${GREEN}Done. $success_count package(s) $action_label successfully.${RESET}"
else
  echo -e "${YELLOW}Done. $success_count package(s) $action_label, $fail_count failed.${RESET}"
fi
