[private]
run-stow +ACTION:
	stow -vv --dotfiles -t ~ -d ./stow/ {{ACTION}}

alias s := stow
stow +args='':
	@just run-stow -S . {{args}}

unstow +args='':
	@just run-stow -D . {{args}}

restow +args='':
	@just run-stow -R . {{args}}

stow-adopt +args='':
	@just run-stow --adopt . {{args}}
