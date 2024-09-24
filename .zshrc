#------------------------------------------------------------------------------
# .zshrc
# Author:    Marcelo Melo
# Source:    http://github.com/mmmmarceleza/dotfiles/.zshrc
# Reference: https://zsh.sourceforge.io/Doc/zsh_a4.pdf (Updated May 14, 2022)
#------------------------------------------------------------------------------

# --------------------------- Path configuration ------------------------------
path=(
    $path                           # Keep existing PATH entries
    $HOME/.local/bin                # My local binaries
    $HOME/.local/bin/scripts        # My local custom scripts
    ${KREW_ROOT:-$HOME/.krew}/bin   # Krew PATH (plugin manager for kubectl)
)
typeset -U path                     # Remove duplicate directories
path=($^path(N-/))                  # Remove non-existent directories
export PATH                         # Export new PATH
# -----------------------------------------------------------------------------

# --------------------------- History configuration ---------------------------
HISTFILE=~/.zhistory        # Historry file location
export HISTSIZE=999999      # The maximum number of events stored in the internal history list
export SAVEHIST=999999      # The maximum number of history events to save in the history file
setopt appendhistory        # Immediately append history instead of overwriting
setopt sharehistory         # share history across all zsh instances
setopt histignorealldups    # If a new command is a duplicate, remove the older one
setopt inc_append_history   # save commands are added to the history immediately, otherwise only when shell exits.
setopt histignorespace      # Don't save commands that start with space
# -----------------------------------------------------------------------------

# ------------------------ Others Options configuration -----------------------
setopt extendedglob         # Extended globbing. Allows using regular expressions with *
setopt nocaseglob           # Case insensitive globbing
setopt rcexpandparam        # Array expension with parameters
setopt nocheckjobs          # Don't warn about running processes when exiting
setopt numericglobsort      # Sort filenames numerically when it makes sense
setopt nobeep               # No beep
setopt autocd               # if only directory path is entered, cd there.
# -----------------------------------------------------------------------------

# --------------------------- Keybindings configuration -----------------------
bindkey -e                                         # Use Emacs keybindings

# Home key bindings for different terminal types
bindkey '^[[7~' beginning-of-line                   # Home key (variant 1) - Move cursor to the beginning of the line
bindkey '^[[H' beginning-of-line                    # Home key (variant 2) - Move cursor to the beginning of the line
if [[ "${terminfo[khome]}" != "" ]]; then
  bindkey "${terminfo[khome]}" beginning-of-line    # Home key based on terminfo - Move to beginning of line
fi

# End key bindings for different terminal types
bindkey '^[[8~' end-of-line                        # End key (variant 1) - Move cursor to the end of the line
bindkey '^[[F' end-of-line                         # End key (variant 2) - Move cursor to the end of the line
if [[ "${terminfo[kend]}" != "" ]]; then
  bindkey "${terminfo[kend]}" end-of-line          # End key based on terminfo - Move to end of line
fi

# Other useful key bindings
bindkey '^[[2~' overwrite-mode                     # Insert key - Toggle overwrite mode
bindkey '^[[3~' delete-char                        # Delete key - Delete the character under the cursor
bindkey '^[[C'  forward-char                       # Right arrow key - Move cursor forward by one character
bindkey '^[[D'  backward-char                      # Left arrow key - Move cursor backward by one character
bindkey '^[[5~' history-beginning-search-backward  # Page Up key - Search history backward from current input
bindkey '^[[6~' history-beginning-search-forward   # Page Down key - Search history forward from current input
bindkey '^[Oc' forward-word                        # Alt + Right Arrow - Move forward by one word
bindkey '^[Od' backward-word                       # Alt + Left Arrow - Move backward by one word
bindkey '^[[1;5D' backward-word                    # Ctrl + Left Arrow - Move cursor back by one word
bindkey '^[[1;5C' forward-word                     # Ctrl + Right Arrow - Move cursor forward by one word
bindkey '^H' backward-kill-word                    # Ctrl + Backspace - Delete the word before the cursor
bindkey '^[[Z' undo                                # Shift + Tab - Undo last change
# -----------------------------------------------------------------------------

# ------------------------ Completion Configuration ------------------------
# Case insensitive tab completion (matches both lower and upper case)
zstyle ':completion:*' matcher-list 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}'  

# Use colored completion (different colors for directories, files, etc.) based on LS_COLORS
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"         

# Automatically detect new executables in the PATH for autocompletion without needing to restart the shell
zstyle ':completion:*' rehash true                              

# force zsh not to show completion menu, which allows fzf-tab to capture the unambiguous prefix
zstyle ':completion:*' menu no

# Accept exact matches, even if they are not readable (speeds up completion)
zstyle ':completion:*' accept-exact '*(N)'                      

# Enable caching for faster autocompletion
zstyle ':completion:*' use-cache on                             

# Define the cache directory for storing autocompletion data
zstyle ':completion:*' cache-path ~/.zsh/cache

# disable sort when completing `git checkout`
zstyle ':completion:*:git-checkout:*' sort false

# set descriptions format to enable group support
# NOTE: don't use escape sequences here, fzf-tab will ignore them
zstyle ':completion:*:descriptions' format '[%d]'

# show systemd unit status
zstyle ':fzf-tab:complete:systemctl-*:*' fzf-preview 'SYSTEMD_COLORS=1 systemctl status $word'

# switch group using `<` and `>`
zstyle ':fzf-tab:*' switch-group '<' '>'

# script ftb-tmux-popup to make full use of it's "popup" feature
zstyle ':fzf-tab:*' popup-min-size 180 12
zstyle ':fzf-tab:*' fzf-command ftb-tmux-popup

# preview directory's and file's content
zstyle ':fzf-tab:complete:*:*' fzf-preview 'less ${(Q)realpath}'
export LESSOPEN='|/home/marcelo/.local/bin/scripts/lessfilter %s'
zstyle ':fzf-tab:complete:*:options' fzf-preview 
zstyle ':fzf-tab:complete:*:argument-1' fzf-preview

zstyle ':fzf-tab:complete:(-command-|-parameter-|-brace-parameter-|export|unset|expand):*' fzf-preview 'echo ${(P)word}'
# -----------------------------------------------------------------------------

# ------------------------- Autoload and Initialization -------------------------
autoload -U compinit colors zcalc
# Autoload functions for completion initialization, color support, and calculator
# - `compinit`: Initializes the completion system
# - `colors`: Enables color support in the terminal
# - `zcalc`: Provides a built-in calculator function

compinit -d
# Initialize the completion system and create a cache for completion data
# The `-d` option specifies that the cache should be saved in the default directory (`~/.zcompdump`)

colors
# Activate color support in the terminal
# Allows the use of color variables for customizing output appearance
# -----------------------------------------------------------------------------

# ---------------------------- Aliases and functions --------------------------
[ -f ~/.shell_aliases ] && . ~/.shell_aliases
[ -f ~/.shell_functions ] && . ~/.shell_functions
[ -f ~/.shell_aliases_private ] && . ~/.shell_aliases_private
[ -f ~/.shell_functions_private ] && . ~/.shell_functions_private
# -----------------------------------------------------------------------------

# --------------------------- Plugins configuration ---------------------------
# install fzf-tab -- https://github.com/Aloxaf/fzf-tab
if [ -d ~/.zshplugins/fzf-tab ]; then
  source ~/.zshplugins/fzf-tab/fzf-tab.plugin.zsh
else
  git clone  https://github.com/Aloxaf/fzf-tab.git ~/.zshplugins/fzf-tab
  source ~/.zshplugins/fzf-tab/fzf-tab.plugin.zsh
fi

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
bindkey '^ ' autosuggest-accept # bind ctrl + space to accept the current suggestion.

# install zsh-completions -- https://github.com/zsh-users/zsh-completions
if [ -d ~/.zshplugins/zsh-completions ]; then
  source ~/.zshplugins/zsh-completions/zsh-completions.plugin.zsh
else
  git clone https://github.com/zsh-users/zsh-completions.git ~/.zshplugins/zsh-completions
  source ~/.zshplugins/zsh-completions/zsh-completions.plugin.zsh
fi
# -----------------------------------------------------------------------------

# ------------------------------ Other settings -------------------------------
# Set default editor to nvim if available, otherwise vim
export EDITOR=${EDITOR:-$(command -v nvim || command -v vim || command -v vi)} 2>/dev/null

# Enabling starship
[ $(command -v starship) ] && eval "$(starship init zsh)" # https://starship.rs/

# Enabling zoxide
[ $(command -v zoxide) ] && eval "$(zoxide init zsh)" # https://github.com/ajeetdsouza/zoxide

# autocompletion for kubectl
[ $(command -v kubectl) ] && source <(kubectl completion zsh) # set up autocomplete in bash into the current shell, bash-completion package should be installed first.

# autocompletion for flux
[ $(command -v flux) ] && source <(flux completion zsh) # set up autocomplete in bash into the current shell, bash-completion package should be installed first.

# enabling aws-assume-role to work as a function
[ -f /home/marcelo/.local/bin/aws-assume-role ] && source /home/marcelo/.local/bin/aws-assume-role 0
# -----------------------------------------------------------------------------

# --------------------------------- Autokube ----------------------------------
## Installed by Autokubectl: https://github.com/caruccio/autokube
[ -f /opt/autokube/autokubeconfig.sh ] && . /opt/autokube/autokubeconfig.sh
[ -f /opt/autokube/autokubectl.sh ] && . /opt/autokube/autokubectl.sh
[ -f /opt/autokube/showkubectl.sh ] && . /opt/autokube/showkubectl.sh
# -----------------------------------------------------------------------------


