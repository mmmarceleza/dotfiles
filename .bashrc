#------------------------------------------------------------------------------
# .bashrc
# Author:    Marcelo Melo
# Source:    http://github.com/mmmmarceleza/dotfiles/.bashrc
# Reference: https://www.gnu.org/software/bash/manual/bash.pdf (September 2022)
#------------------------------------------------------------------------------

# --------------------------- Path configuration ------------------------------
# adding ~/.local/bin in the PATH variable
if [ -d "$HOME/.local/bin" ] && [ "${PATH#*"$HOME"/.local/bin}" == "$PATH" ]; then
    export PATH="$HOME/.local/bin:$PATH"
fi
# adding ~/.local/bin/scripts in the PATH variable
if [ -d "$HOME/.local/bin/scripts" ] && [ "${PATH#*"$HOME"/.local/bin/scripts}" == "$PATH" ]; then
    export PATH="$HOME/.local/bin/scripts:$PATH"
fi
# adding Krew folder to the PATH (https://krew.sigs.k8s.io/)
if [ -d "$HOME/.krew/bin" ] && [ "${PATH#*"$HOME"/.krew/bin}" == "$PATH" ]; then
    export PATH="$HOME/.krew/bin:$PATH"
fi
# -----------------------------------------------------------------------------


# Bash Variables
export HISTFILESIZE=999999
export HISTSIZE=999999
# Don't record some commands
export HISTIGNORE="&:[ ]*:exit:ls:bg:fg:history:clear"
# A colon-separated list of values controlling how commands are saved on the history list
HISTCONTROL="erasedups:ignoreboth"

# Set default editor to nvim if available, otherwise vim
export EDITOR=${EDITOR:-$(command -v nvim || command -v vim || command -v vi)} 2>/dev/null

# importing my aliases and fuctions
[ -f ~/.shell_aliases ] && . ~/.shell_aliases
[ -f ~/.shell_functions ] && . ~/.shell_functions
[ -f ~/.shell_aliases_private ] && . ~/.shell_aliases_private
[ -f ~/.shell_functions_private ] && . ~/.shell_functions_private
[ -f /opt/autokube/autokubectl.sh ] && . /opt/autokube/autokubectl.sh


# enabling zoxide
[ $(command -v zoxide) ] && eval "$(zoxide init bash)" # https://github.com/ajeetdsouza/zoxide

# enabling starship
[ $(command -v starship) ] && eval "$(starship init bash)" # https://starship.rs/

# autocompletion for kubectl
[ $(command -v kubectl) ] && source <(kubectl completion bash) # set up autocomplete in bash into the current shell, bash-completion package should be installed first.
[ $(command -v kubectl) ] && alias k=kubectl; complete -o default -F __start_kubectl k

# autocompletion for flux
[ $(command -v flux) ] && source <(flux completion bash) # set up autocomplete in bash into the current shell, bash-completion package should be installed first.

# enabling aws-assume-role to work as a function
[ -f /home/marcelo/.local/bin/aws-assume-role ] && source /home/marcelo/.local/bin/aws-assume-role 0
## Installed by Autokubectl: https://github.com/caruccio/autokube
# source /home/marcelo/git/getup/getup/autokube/autokubeconfig.sh
# source /home/marcelo/git/getup/getup/autokube/autokubectl.sh
# source /home/marcelo/git/getup/getup/autokube/showkubectl.sh
