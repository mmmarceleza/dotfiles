
.PHONY: git
git:
	stow -vt ~ git

.PHONY: konsole
konsole:
	# prerequisites: ttf-hack-nerd font
	stow -vt ~ konsole

.PHONY: nvim
nvim:
	# prerequisites: git, make, pip, python, npm, node, lazygit, fzf and cargo
	stow -vt ~ nvim

.PHONY: nvim
nvim-unstow:
	stow -vDt ~ nvim

.PHONY: zsh
zshrc:
	stow -vt ~ zsh
	line1='[ -f ~/.shell_aliases ] && . ~/.shell_aliases'
	if grep -q "$line1" ~/.zshrc; then
		echo "The line '$line1' already exists in the file."
	else
		echo $line1 >> ~/.zshrc
		echo "The line '$line1' has been added in .zshrc"
	fi
	line2='[ -f ~/.shell_functions ] && . ~/.shell_functions'
	if grep -q "$line2" ~/.zshrc; then
		echo "The line '$line2' already exists in the file."
	else
		echo $line2 >> ~/.zshrc
		echo "The line '$line2' has been added in .zshrc"
	fi
