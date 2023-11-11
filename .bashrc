#------------------------------------------------------------------------------
# .bashrc
# Author: Marcelo Melo
# Source: http://github.com/mmmmarceleza/dotfiles/.bashrc
#------------------------------------------------------------------------------

# Bash Variables
export HISTFILESIZE=999999
export HISTSIZE=999999

# Set default editor to nvim if available, otherwise vim
export EDITOR=${EDITOR:-$(which nvim || which vim || which vi)} 2>/dev/null

# importing my aliases and fuctions
[ -f ~/.shell_aliases ] && . ~/.shell_aliases
[ -f ~/.shell_functions ] && . ~/.shell_functions
[ -f ~/.shell_aliases_private ] && . ~/.shell_aliases_private
[ -f ~/.shell_functions_private ] && . ~/.shell_functions_private

# adding ~/.local/bin in the PATH variable
[ -d ~/.local/bin ] && export PATH=/home/marcelo/.local/bin:$PATH

# adding Krew folder to the PATH (https://krew.sigs.k8s.io/)
[ -d ~/.krew/bin ] && export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"

