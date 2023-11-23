#------------------------------------------------------------------------------
# .zshrc
# Author: Marcelo Melo
# Source: http://github.com/mmmmarceleza/dotfiles/.zshrc
#------------------------------------------------------------------------------

## Options section
setopt correct                                                  # Auto correct mistakes
setopt extendedglob                                             # Extended globbing. Allows using regular expressions with *
setopt nocaseglob                                               # Case insensitive globbing
setopt rcexpandparam                                            # Array expension with parameters
setopt nocheckjobs                                              # Don't warn about running processes when exiting
setopt numericglobsort                                          # Sort filenames numerically when it makes sense
setopt nobeep                                                   # No beep
setopt appendhistory                                            # Immediately append history instead of overwriting
setopt histignorealldups                                        # If a new command is a duplicate, remove the older one
setopt autocd                                                   # if only directory path is entered, cd there.
setopt inc_append_history                                       # save commands are added to the history immediately, otherwise only when shell exits.
setopt histignorespace                                          # Don't save commands that start with space

zstyle ':completion:*' matcher-list 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' # Case insensitive tab completion
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"         # Colored completion (different colors for dirs/files/etc)
zstyle ':completion:*' rehash true                              # automatically find new executables in path 
zstyle ':completion:*' menu select                              # Highlight menu selection
# Speed up completions
zstyle ':completion:*' accept-exact '*(N)'
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.zsh/cache
HISTFILE=~/.zhistory
export HISTFILESIZE=999999
export HISTSIZE=999999

## Keybindings section
bindkey -e
bindkey '^[[7~' beginning-of-line                               # Home key
bindkey '^[[H' beginning-of-line                                # Home key
if [[ "${terminfo[khome]}" != "" ]]; then
  bindkey "${terminfo[khome]}" beginning-of-line                # [Home] - Go to beginning of line
fi
bindkey '^[[8~' end-of-line                                     # End key
bindkey '^[[F' end-of-line                                     # End key
if [[ "${terminfo[kend]}" != "" ]]; then
  bindkey "${terminfo[kend]}" end-of-line                       # [End] - Go to end of line
fi
bindkey '^[[2~' overwrite-mode                                  # Insert key
bindkey '^[[3~' delete-char                                     # Delete key
bindkey '^[[C'  forward-char                                    # Right key
bindkey '^[[D'  backward-char                                   # Left key
bindkey '^[[5~' history-beginning-search-backward               # Page up key
bindkey '^[[6~' history-beginning-search-forward                # Page down key

# Navigate words with ctrl+arrow keys
bindkey '^[Oc' forward-word                                     #
bindkey '^[Od' backward-word                                    #
bindkey '^[[1;5D' backward-word                                 #
bindkey '^[[1;5C' forward-word                                  #
bindkey '^H' backward-kill-word                                 # delete previous word with ctrl+backspace
bindkey '^[[Z' undo                                             # Shift+tab undo last action

# Theming section  
autoload -U compinit colors zcalc
compinit -d
colors
# Color man pages
export LESS_TERMCAP_mb=$'\E[01;32m'
export LESS_TERMCAP_md=$'\E[01;32m'
export LESS_TERMCAP_me=$'\E[0m'
export LESS_TERMCAP_se=$'\E[0m'
export LESS_TERMCAP_so=$'\E[01;47;34m'
export LESS_TERMCAP_ue=$'\E[0m'
export LESS_TERMCAP_us=$'\E[01;36m'
export LESS=-R

## Plugins section: Enable fish style features
# Use syntax highlighting
#source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
# Use history substring search
#source /usr/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh
# bind UP and DOWN arrow keys to history substring search

# Set default editor to nvim if available, otherwise vim
export EDITOR=${EDITOR:-$(command -v nvim || command -v vim || command -v vi)} 2>/dev/null

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

# autocompletion for kubectl
[ $(command -v kubectl) ] && source <(kubectl completion zsh) # set up autocomplete in bash into the current shell, bash-completion package should be installed first.

# autocompletion for flux
[ $(command -v flux) ] && source <(flux completion zsh) # set up autocomplete in bash into the current shell, bash-completion package should be installed first.

# install zsh-syntax-highlighting -- https://github.com/zsh-users/zsh-syntax-highlighting
if [ -d ~/.zshplugins/zsh-syntax-highlighting ]; then
  source ~/.zshplugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
else
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.zshplugins/zsh-syntax-highlighting
  source ~/.zshplugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

# install zsh-autosuggestions -- https://github.com/zsh-users/zsh-autosuggestions
if [ -d ~/.zshplugins/zsh-autosuggestions ]; then
  source ~/.zshplugins/zsh-autosuggestions/zsh-autosuggestions.zsh
else
  git clone https://github.com/zsh-users/zsh-autosuggestions.git ~/.zshplugins/zsh-autosuggestions
  source ~/.zshplugins/zsh-autosuggestions/zsh-autosuggestions.zsh
fi
