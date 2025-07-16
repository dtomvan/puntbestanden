# Puntbestanden

> Literally means "dotfiles" in Dutch: "punt" = "dot", "bestanden" = "files"

What's in here:
- 5 NixOS configs- a dendritic home-manager config (TODO: list aspects here)- An unhinged Emacs config
- A lot less lines of neovim lua config compared to my [previous attempt](https://github.com/dtomvan/.config/tree/main/neovim/.config/nvim)
# Dendritic
This repository uses the [dendritic](https://github.com/mightyiam/dendritic)
pattern for monolithic, interconnected NixOS/HomeManager/Nixvim configs.
Hence it also uses [flake.parts](https://flake.parts/). This might throw you
off if you are new to nix and/or nix flakes. You've been warned!

It is meant to make configurations more modular, flexible, and shareable
though, so I encourage you to learn from it if you do so desire. If you
understand flake.parts, all you need to know is that (almost) **every nix
file in this tree is a flake.parts module**.

Learn more about it (in order of, well, "deepness" or complexity):
  - https://flake.parts/
  - https://flake.parts/options/flake-parts-modules.html
  - https://github.com/mightyiam/dendritic
  - https://github.com/vic/import-tree/
  - https://github.com/vic/flake-file/
## The hostnames

- `boomer`, a reasonably sluggish Ryzen 5 2600 desktop PC
- `kaput`, a thick bastard of a laptop with a broken screen
- `feather`, the ultra-light Thinkpad X1 Carbon G8
# Autounattend
This repository includes an "autounattend" installer ISO, which:
- Installs a nested, pre-defined NixOS configuration
- Without any user interaction required apart from booting it
- Also automatically partitions through disko
- Does not require internet

To create the iso, run `nix build .#autounattend-iso`.

To run an install demo in QEMU, run `nix run .#install-demo`.

If you do not have access to the secrets in this repo you'll need to
comment out the `networking-wifi-passwords` import in order to build it.

Beware: the eval time (and disk usage) is very inefficient, because it
seems like nix wants to copy around some `source` directory through the
store a couple of times. it is a cool party trick though.
## At home

NEW: you can do this in YOUR repo too, with your own target config!

```nix
{
  inputs.flake-parts.url = "github:hercules-ci/flake-parts";
  inputs.import-tree.url = "github:vic/import-tree";
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  inputs.dtomvan = {
    url = "github:dtomvan/puntbestanden?subdir=modules/community";
    flake = false;
  };
  inputs.disko = {
    url = "github:nix-community/disko/latest";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs @ {
    flake-parts,
    import-tree,
    nixpkgs,
    dtomvan,
    ...
  }:
  flake-parts.lib.mkFlake { inherit inputs; } {
    imports = [
      flake-parts.flakeModules.modules
      (import-tree "${dtomvan}/autounattend")
    ];

    # needed so the installer partitions the same way you mount your
    # filesystems later
    autounattend.diskoFile = ./disko.nix;

    flake.nixosConfigurations.autounattend = nixpkgs.lib.nixosSystem {
      modules = [
        ./configuration.nix
        ./disko.nix
        disko.nixosModules.disko
      ];
    };
  };
}
```
## For myself: How to bootstrap `localsend-rs` inside of the flake

- Have one of the private keys corresponding to a pubkey listed in `.sops.yaml`
  in `~/.config/sops/age/keys.txt`.
- `nix run nixpkgs#sops -- decrypt secrets/localsend-rs.secret`
- Copy the access token
- `nix flake lock --extra-access-tokens "$accesstoken"`
- `nh os switch`

Afterwards, through the nixos module, the secret will get loaded into
`nix.conf` and you can `nix flake update` for example without any manual setup
