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
stow-tom-pc:
	@just stow kde-common kde-tom-pc

[group('stow')]
stow-tom-laptop:
	@just stow kde-common kde-tom-laptop

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
	nh home switch -c "{{home}}" .

alias upo := update-os
[group('nix')]
update-os:
	nh os switch # only works on nixos, so we don't include an option to change which one to update

[group('nix')]
up: update-flake update-home


