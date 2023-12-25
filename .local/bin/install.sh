#!/bin/bash

git clone --bare https://github.com/mmmarceleza/dotfiles.git "$HOME"/.dotfiles
function config {
   /usr/bin/git --git-dir="$HOME"/.dotfiles/ --work-tree="$HOME" "$@"
}
mkdir -p "$HOME"/.config-backup
cd "$HOME" || { echo "Failure"; exit 1; }
if [ "$(config checkout 2>/dev/null)" ]; then
  echo "Checked out config.";
  else
    echo "Backing up pre-existing dot files to $HOME/.config-backup/";
    config checkout 2>&1 | grep -E "\s+\." | awk '{print $1}' | xargs -I{} mv {} .config-backup/{}
fi;
config checkout
config config status.showUntrackedFiles no
echo "Reload your shell"
