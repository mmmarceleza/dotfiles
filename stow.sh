#!/bin/bash

set -euo pipefail

# Determine the directory where this script is located (dotfiles root)
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Target directory where symlinks will be created (usually the home directory)
TARGET_DIR="$HOME"

# Determine which directories to stow (use arguments or all subdirectories)
STOW_DIRS=("$@")
if [[ ${#STOW_DIRS[@]} -eq 0 ]]; then
  STOW_DIRS=()
  for d in "$DOTFILES_DIR"/*/; do
    STOW_DIRS+=("$(basename "${d%/}")")
  done
fi

echo "Applying dotfiles to: $TARGET_DIR"
for dir in "${STOW_DIRS[@]}"; do
  echo "Stowing: $dir"
  stow --target="$TARGET_DIR" --dir="$DOTFILES_DIR" --stow "$dir"
done

echo "Dotfiles successfully applied."

