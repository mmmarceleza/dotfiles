#!/usr/bin/env bash
set -euo pipefail

# ----------------------------
# Color definitions
# ----------------------------
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
BLUE="\033[1;34m"
RESET="\033[0m"

# ----------------------------
# Helper: print usage
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
# Check dependencies
# ----------------------------
if ! command -v stow >/dev/null 2>&1; then
  echo -e "${RED}Error: 'stow' is not installed or not in PATH.${RESET}" >&2
  exit 1
fi

# ----------------------------
# Initialization
# ----------------------------
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="$HOME"
ACTION="--stow"
DRY_RUN=false
VERBOSE=false
STOW_DIRS=()

# ----------------------------
# Argument parsing
# ----------------------------
while [[ $# -gt 0 ]]; do
  case "$1" in
    --uninstall)
      ACTION="--delete"
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
    --help)
      usage
      ;;
    -*)
      echo -e "${RED}Unknown option: $1${RESET}" >&2
      usage
      ;;
    *)
      STOW_DIRS+=("$1")
      shift
      ;;
  esac
done

# ----------------------------
# Discover packages (if none specified)
# ----------------------------
if [[ ${#STOW_DIRS[@]} -eq 0 ]]; then
  for d in "$DOTFILES_DIR"/*/; do
    STOW_DIRS+=("$(basename "${d%/}")")
  done
fi

# ----------------------------
# Validate directories
# ----------------------------
for dir in "${STOW_DIRS[@]}"; do
  if [[ ! -d "$DOTFILES_DIR/$dir" ]]; then
    echo -e "${RED}Error: Package directory '$dir' does not exist in $DOTFILES_DIR${RESET}" >&2
    exit 1
  fi
done

# ----------------------------
# Summary
# ----------------------------
echo -e "${BLUE}Dotfiles directory:${RESET} $DOTFILES_DIR"
echo -e "${BLUE}Target directory:  ${RESET} $TARGET_DIR"
echo -e "${BLUE}Action:            ${RESET} $ACTION"
$DRY_RUN && echo -e "${YELLOW}Dry-run enabled${RESET}"
$VERBOSE && echo -e "${BLUE}Verbose output:    ${RESET} enabled"
echo -e "${BLUE}Packages:          ${RESET} ${STOW_DIRS[*]}"
echo

# ----------------------------
# Apply or simulate
# ----------------------------
for dir in "${STOW_DIRS[@]}"; do
  echo -e "${GREEN}Processing: $dir${RESET}"
  CMD=(stow --target="$TARGET_DIR" --dir="$DOTFILES_DIR" "$ACTION")
  $VERBOSE && CMD+=("--verbose")
  CMD+=("$dir")

  if $DRY_RUN; then
    echo -e "${YELLOW}Would run:${RESET} ${CMD[*]}"
  else
    if ! OUTPUT="$("${CMD[@]}" 2>&1)"; then
      echo -e "${RED}Error processing package: $dir${RESET}"
      echo "$OUTPUT"
    else
      [[ -n "$OUTPUT" ]] && echo "$OUTPUT"
    fi
  fi
done

echo -e "\n${GREEN}Done.${RESET}"

