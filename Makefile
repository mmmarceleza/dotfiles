SHELL = /bin/zsh
.ONESHELL:
.EXPORT_ALL_VARIABLES:
.PHONY: git konsole nvim nvim-unstow zshrc

git:
	stow -vt ~ git

konsole:
	# prerequisites: ttf-hack-nerd font
	stow -vt ~ konsole

nvim:
	# prerequisites: git, make, pip, python, npm, node, lazygit, fzf and cargo
	stow -vt ~ nvim

nvim-unstow:
	stow -vDt ~ nvim

LINE1 = '[ -f ~/.shell_aliases ] && . ~/.shell_aliases'
LINE2 = '[ -f ~/.shell_functions ] && . ~/.shell_functions'

zshrc:
	@stow -vt ~ zsh
	@if grep -q $(LINE1) ~/.zshrc; then
		echo "The line $(LINE1) already exists in the file."
	else
		echo $(LINE1) >> ~/.zshrc
		echo "The line $(LINE1) has been added in .zshrc"
	fi
	@if grep -q $(LINE2) ~/.zshrc; then
		echo "The line $(LINE2) already exists in the file."
	else
		echo $(LINE2) >> ~/.zshrc
		echo "The line $(LINE2) has been added in .zshrc"
	fi

