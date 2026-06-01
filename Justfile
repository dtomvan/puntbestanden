default:
    @just --list

check:
    nix run .#write-flake
    nix fmt
    nix run .#write-files
    nix flake check

clean:
    rm -f result* repl-result*

deploy panixargs='' deploy-rsargs='':
    nix develop -c panix deploy --exit-on-complete --log {{panixargs}}
    nix develop -c deploy -sk {{deploy-rsargs}}

all: check deploy

push WHAT:
    jj git push -c @-
    fj --host git.toostveen.nl pr create \
        --head "$(jj show -r 'closest_bookmark(@)' -T 'bookmarks.map(|b| b.name())' --no-patch | tr ' ' '\n' | sort | head -n1)" \
        --base hoofdlijn \
        --autofill

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
