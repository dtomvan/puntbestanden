[private]
run-stow PACKAGE +ACTION:
	stow -vv --dotfiles -t ~ -d ./stow {{PACKAGE}} {{ACTION}}

alias s := stow
stow PACKAGE='tom-pc' +args='':
	@just run-stow {{PACKAGE}} -S . {{args}}

unstow PACKAGE='tom-pc' +args='':
	@just run-stow {{PACKAGE}} -D . {{args}}

restow PACKAGE='tom-pc' +args='':
	@just run-stow {{PACKAGE}} -R . {{args}}

stow-adopt PACKAGE='tom-pc' +args='':
	@just run-stow {{PACKAGE}} --adopt . {{args}}
