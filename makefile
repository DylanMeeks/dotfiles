
all:
	stow --verbose --target=$HOME --restow */

delete:
	stow --verbose --target=$$HOME --delete */

hypr:
	stow --verbose --target=$HOME --restow hypr 
	stow --verbose --target=$HOME --restow swaylock
	stow --verbose --target=$HOME --restow waybar
	stow --verbose --target=$HOME --restow wlogout
	stow --verbose --target=$HOME --restow wofi

ghostty:
	stow --verbose --target=$HOME --restow ghostty
	stow --verbose --target=$HOME --restow zsh

zsh:
	stow --verbose --target=$HOME --restow zsh

