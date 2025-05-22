# Puntbestanden

> Literally means "dotfiles" in Dutch: "punt" = "dot", "bestanden" = "files"

What's in here:
- 3 nixos configs
- a generic home-manager config which has "specializations" based of properties of specific hosts (see `hosts.nix`)
    - neovim
    - helix
    - [plasma-manager](https://github.com/nix-community/plasma-manager)
    - hyprland
    - various terminals (alacritty, foot, ghostty, konsole)
- 8 firefox extensions from source
- 1 font
- 4 clojure utilities
- `home/lib/a-fuckton-of-git-aliases.nix` :)
- An unhinged Emacs config
- A lot less lines of neovim lua config compared to my [previous attempt](https://github.com/dtomvan/.config/tree/main/neovim/.config/nvim)

## The hostnames

- `boomer`, a reasonably sluggish Ryzen 5 2600 desktop PC.
- `feather`, the ultra-light Thinkpad X1 Carbon G8
- `kaput`, a thick bastard of a laptop with a broken screen

## For myself: How to bootstrap `localsend-rs` inside of the flake

- Have one of the private keys corresponding to a pubkey listed in `.sops.yaml`
  in `~/.config/sops/age/keys.txt`.
- `nix run nixpkgs#sops -- decrypt secrets/localsend-rs.secret`
- Copy the access token
- `nix flake lock --extra-access-tokens "$accesstoken"`
- `nh os switch`

Afterwards, through the nixos module, the secret will get loaded into
`nix.conf` and you can `nix flake update` for example without any manual setup
