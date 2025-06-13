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
# adding Applications folder to the PATH (appimage default application folder)
if [ -d "$HOME/Applications" ] && [ "${PATH#*"$HOME"/Applications}" == "$PATH" ]; then
    export PATH="$HOME/Applications:$PATH"
fi
# -----------------------------------------------------------------------------

# --------------------------- History configuration ---------------------------
export HISTFILESIZE=999999
export HISTSIZE=999999
export HISTIGNORE="&:[ ]*:exit:ls:bg:fg:history:clear"
HISTCONTROL="erasedups:ignoreboth"
# -----------------------------------------------------------------------------

# ---------------------------- Aliases and functions --------------------------
[ -f ~/.shell_aliases ] && . ~/.shell_aliases
[ -f ~/.shell_functions ] && . ~/.shell_functions
[ -f ~/.shell_aliases_private ] && . ~/.shell_aliases_private
[ -f ~/.shell_functions_private ] && . ~/.shell_functions_private
# -----------------------------------------------------------------------------

# ------------------------------ Other settings -------------------------------
# Set default editor to nvim if available, otherwise vim
export EDITOR=${EDITOR:-$(command -v nvim || command -v vim || command -v vi)} 2>/dev/null
#
# enabling zoxide
[ "$(command -v zoxide)" ] && eval "$(zoxide init bash)" # https://github.com/ajeetdsouza/zoxide

# enabling starship
[ "$(command -v starship)" ] && eval "$(starship init bash)" # https://starship.rs/

# autocompletion for kubectl
[ "$(command -v kubectl)" ] && source <(kubectl completion bash) # set up autocomplete in bash into the current shell, bash-completion package should be installed first.
[ "$(command -v kubectl)" ] && alias k=kubectl; complete -o default -F __start_kubectl k

# autocompletion for flux
[ "$(command -v flux)" ] && source <(flux completion bash) # set up autocomplete in bash into the current shell, bash-completion package should be installed first.

# autocompletion for argocd
[ "$(command -v arogcd)" ] && source <(argocd completion bash) # set up autocomplete in bash into the current shell, bash-completion package should be installed first.

# enabling aws-assume-role to work as a function
[ -f /home/marcelo/.local/bin/scripts/aws-assume-role ] && source /home/marcelo/.local/bin/scripts/aws-assume-role 0
# -----------------------------------------------------------------------------

# --------------------------------- Autokube ----------------------------------
## Installed by Autokubectl: https://github.com/caruccio/autokube
[ -f /opt/autokube/autokubeconfig.sh ] && . /opt/autokube/autokubeconfig.sh
[ -f /opt/autokube/autokubectl.sh ] && . /opt/autokube/autokubectl.sh
[ -f /opt/autokube/showkubectl.sh ] && . /opt/autokube/showkubectl.sh
# -----------------------------------------------------------------------------

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/home/marcelo/Downloads/google-cloud-sdk/path.bash.inc' ]; then . '/home/marcelo/Downloads/google-cloud-sdk/path.bash.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/home/marcelo/Downloads/google-cloud-sdk/completion.bash.inc' ]; then . '/home/marcelo/Downloads/google-cloud-sdk/completion.bash.inc'; fi

# autocompletion for terragrunt
[ "$(command -v terragrunt)" ] && complete -C /usr/bin/terragrunt terragrunt

# Set up fzf key bindings and fuzzy completion
[ "$(command -v fzf)" ] && eval "$(fzf --bash)"
