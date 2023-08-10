
.PHONY: git
git:
	stow -vt ~ git

.PHONY: konsole
konsole:
	stow -vt ~ konsole

.PHONY: nvim
konsole:
	stow -vt ~ nvim

.PHONY: stow
unstow:
	stow -vDt ~ konsole
