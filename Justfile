default:
    @just --list

check:
    nix run .#write-flake
    nix fmt
    nix run .#write-files
    nix flake check

clean:
    rm -f result* repl-result*

build:
    nix run .#nix-build-all

deploy:
    nix develop -c deploy -sk

cleanbuild: clean build
all: check cleanbuild deploy

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
stow-nvim +args='':
	@just stow nvim {{args}}
