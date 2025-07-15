[group('nix')]
nix +args='':
	nix --experimental-features="nix-command flakes" {{args}}

alias upf := update-flake
[group('nix')]
update-flake:
	@just nix flake update

alias uph := update-home
[group('nix')]
update-home:
    nh home switch

alias upo := update-os
[group('nix')]
update-os:
	nh os boot

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

[group('nix')]
update-files:
    nix run .#write-flake
    nix run .#write-files

[group('nix')]
check:
    nix fmt
    @just update-files
    nix flake check
