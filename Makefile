
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

.PHONY: stow
unstow:
	stow -vDt ~ konsole
