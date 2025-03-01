[private]
run-stow ACTION PACKAGE +ARGS='':
	stow -vv --dotfiles -t ~ -d ./stow {{ACTION}} {{PACKAGE}} {{ARGS}}

alias s := stow
stow PACKAGE +args='':
	@just run-stow -S {{PACKAGE}} {{args}}

[group('stow')]
unstow PACKAGE +args='':
	@just run-stow -D {{PACKAGE}} {{args}}

[group('stow')]
restow PACKAGE +args='':
	@just run-stow -R {{PACKAGE}} {{args}}

[group('stow')]
stow-adopt PACKAGE +args='':
	@just run-stow --adopt {{PACKAGE}} {{args}}

[group('stow')]
stow-tom-pc +args='':
	@just stow kde-common kde-tom-pc {{args}}

[group('stow')]
stow-tom-laptop +args='':
	@just stow kde-common kde-tom-laptop {{args}}

####################################################################################################

[group('nix')]
nix +args='':
	nix --experimental-features="nix-command flakes" {{args}}

alias upf := update-flake
[group('nix')]
update-flake:
	@just nix flake update

alias uph := update-home
[group('nix')]
update-home +home="{{shell('whoami')}}@{{shell('hostname')}}":
	nix-fast-build -f ".#homeConfigurations.{{home}}.activationPackage"
	./result-/activate

alias upo := update-os
[group('nix')]
update-os:
	nh os switch

[group('nix')]
up: update-flake update-home

