[group('nix')]
nix +args='':
	nix --experimental-features="nix-command flakes" {{args}}

alias upf := update-flake
[group('nix')]
update-flake:
	@just nix flake update

alias uph := update-home
[group('nix')]
update-home user=shell("whoami") host=shell("hostname"):
	nix-fast-build -f ".#homeConfigurations.{{user}}@{{host}}.activationPackage"
	./result-/activate

alias upo := update-os
[group('nix')]
update-os:
	nh os switch

[group('nix')]
up: update-flake update-os update-home

[group('nix')]
feather:
    nix run .#feather

[group('nix')]
boomer:
    nix run .#boomer

[group('nix')]
kaput:
    nix run .#kaput
