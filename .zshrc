#------------------------------------------------------------------------------
# .zshrc
# Author: Marcelo Melo
# Source: http://github.com/mmmmarceleza/dotfiles/.zshrc
#------------------------------------------------------------------------------

# ZSH Variables

export HISTFILESIZE=999999
export HISTSIZE=999999
# Don't record some commands
# export HISTIGNORE="&:[ ]*:exit:ls:bg:fg:history:clear"
# A colon-separated list of values controlling how commands are saved on the history list
# HISTCONTROL="erasedups:ignoreboth"

# Set default editor to nvim if available, otherwise vim
export EDITOR=${EDITOR:-$(command -v nvim || command -v vim || command -v vi)} 2>/dev/null

# Use powerline
#USE_POWERLINE="true"
## Source manjaro-zsh-configuration
#if [[ -e /usr/share/zsh/manjaro-zsh-config ]]; then
#  source /usr/share/zsh/manjaro-zsh-config
#fi
## Use manjaro zsh prompt
#if [[ -e /usr/share/zsh/manjaro-zsh-prompt ]]; then
#  source /usr/share/zsh/manjaro-zsh-prompt
#fi

# enabling starship
[ $(command -v starship) ] && eval "$(starship init zsh)" # https://starship.rs/

# importing my aliases and fuctions
[ -f ~/.shell_aliases ] && . ~/.shell_aliases
[ -f ~/.shell_functions ] && . ~/.shell_functions
[ -f ~/.shell_aliases_private ] && . ~/.shell_aliases_private
[ -f ~/.shell_functions_private ] && . ~/.shell_functions_private

# adding ~/.local/bin in the PATH variable
[ -d ~/.local/bin ] && export PATH=/home/marcelo/.local/bin:$PATH

# adding Krew folder to the PATH (https://krew.sigs.k8s.io/)
[ -d ~/.krew/bin ] && export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"

[ $(command -v zoxide) ] && eval "$(zoxide init zsh)" # https://github.com/ajeetdsouza/zoxide

