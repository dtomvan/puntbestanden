# Puntbestanden

> Literally means "dotfiles" in Dutch: "punt" = "dot", "bestanden" = "files"

What's in here:

- 5 NixOS configs
- a dendritic home-manager config (TODO: list aspects here)
- An unhinged Emacs config
- A lot less lines of neovim lua config compared to my [previous attempt](https://github.com/dtomvan/.config/tree/main/neovim/.config/nvim)

## The hostnames

- `boomer`, a reasonably sluggish Ryzen 5 2600 desktop PC
- `kaput`, a thick bastard of a laptop with a broken screen
- `feather`, the ultra-light Thinkpad X1 Carbon G8

# Autounattend
This repository includes an "autounattend" installer ISO, which:
- Installs a nested, pre-defined NixOS configuration
- Without any user interaction required apart from booting it
- Does not require internet

To create the iso, run `nix build .#iso`.

To run an install demo in QEMU, run `nix run .#install-demo`.

If you do not have access to the secrets in this repo you'll need to
comment out the `networking-wifi-passwords` import in order to build it.

## For myself: How to bootstrap `localsend-rs` inside of the flake

- Have one of the private keys corresponding to a pubkey listed in `.sops.yaml`
in `~/.config/sops/age/keys.txt`.
- `nix run nixpkgs#sops -- decrypt secrets/localsend-rs.secret`
- Copy the access token
- `nix flake lock --extra-access-tokens "$accesstoken"`
- `nh os switch`

Afterwards, through the nixos module, the secret will get loaded into
`nix.conf` and you can `nix flake update` for example without any manual setup

