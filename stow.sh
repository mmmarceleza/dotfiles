#!/usr/bin/env bash
set -euo pipefail

# ----------------------------
# Color definitions for output formatting
# ----------------------------
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
BLUE="\033[1;34m"
RESET="\033[0m"

# ----------------------------
# Helper function: print usage instructions
# ----------------------------
usage() {
  echo -e "${BLUE}Usage:${RESET}"
  echo "  $(basename "$0") [options] [package1 package2 ...]"
  echo
  echo -e "${BLUE}Options:${RESET}"
  echo "  --uninstall      Unlink instead of stow"
  echo "  --dry-run        Show actions without applying"
  echo "  --verbose        Show verbose output from stow"
  echo "  --help           Show this help message"
  echo
  echo -e "${BLUE}Examples:${RESET}"
  echo "  $(basename "$0")                    # Apply all dotfiles"
  echo "  $(basename "$0") bash nvim          # Apply specific packages"
  echo "  $(basename "$0") --uninstall nvim"
  echo "  $(basename "$0") --dry-run wezterm"
  echo "  $(basename "$0") --verbose"
  exit 0
}

# ----------------------------
# Check if 'stow' is installed
# ----------------------------
if ! command -v stow >/dev/null 2>&1; then
  echo -e "${RED}Error: 'stow' is not installed or not in PATH.${RESET}" >&2
  exit 1
fi

# ----------------------------
# Initialization of variables
# ----------------------------
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)" # Directory containing this script
TARGET_DIR="$HOME"      # Where dotfiles will be stowed (usually $HOME)
ACTION="--stow"         # Default action is to stow (link files)
DRY_RUN=false           # If true, only simulate actions
VERBOSE=false           # If true, show verbose output
STOW_DIRS=()            # List of packages to stow

# ----------------------------
# Parse command-line arguments
# ----------------------------
while [[ $# -gt 0 ]]; do
  case "$1" in
    --uninstall)
      ACTION="--delete" # Change action to delete (unstow)
      shift
      ;;
    --dry-run)
      DRY_RUN=true      # Enable dry-run mode
      shift
      ;;
    --verbose)
      VERBOSE=true      # Enable verbose output
      shift
      ;;
    --help)
      usage             # Show usage and exit
      ;;
    -*)
      echo -e "${RED}Unknown option: $1${RESET}" >&2
      usage
      ;;
    *)
      STOW_DIRS+=("$1") # Add package to list
      shift
      ;;
  esac
done

# ----------------------------
# If no packages specified, stow all directories in DOTFILES_DIR
# ----------------------------
if [[ ${#STOW_DIRS[@]} -eq 0 ]]; then
  for d in "$DOTFILES_DIR"/*/; do
    STOW_DIRS+=("$(basename "${d%/}")")
  done
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
# Print summary of actions to be performed
# ----------------------------
echo -e "${BLUE}Dotfiles directory:${RESET} $DOTFILES_DIR"
echo -e "${BLUE}Target directory:  ${RESET} $TARGET_DIR"
echo -e "${BLUE}Action:            ${RESET} $ACTION"
$DRY_RUN && echo -e "${YELLOW}Dry-run enabled${RESET}"
$VERBOSE && echo -e "${BLUE}Verbose output:    ${RESET} enabled"
echo -e "${BLUE}Packages:          ${RESET} ${STOW_DIRS[*]}"
echo

# ----------------------------
# Apply stow/uninstall for each package
# ----------------------------
for dir in "${STOW_DIRS[@]}"; do
  echo -e "${GREEN}Processing: $dir${RESET}"
  CMD=(stow --target="$TARGET_DIR" --dir="$DOTFILES_DIR" "$ACTION")
  $VERBOSE && CMD+=("--verbose")
  CMD+=("$dir")

  if $DRY_RUN; then
    # Show what would be run, but do not execute
    echo -e "${YELLOW}Would run:${RESET} ${CMD[*]}"
  else
    # Run the stow command and handle errors/output
    if ! OUTPUT="$("${CMD[@]}" 2>&1)"; then
      echo -e "${RED}Error processing package: $dir${RESET}"
      echo "$OUTPUT"
    else
      [[ -n "$OUTPUT" ]] && echo "$OUTPUT"
    fi
  fi
done

echo -e "\n${GREEN}Done.${RESET}"