# Puntbestanden

> Literally means "dotfiles" in Dutch: "punt" = "dot", "bestanden" = "files"

What's in here:
- 8 NixOS configs (well, this is a generated number so it's technically correct but don't over-estimate me)
- a dendritic home-manager config (TODO: list aspects here)
- An unhinged Emacs config
- A lot less lines of neovim lua config compared to my [previous attempt](https://github.com/dtomvan/.config/tree/main/neovim/.config/nvim)
- A clone of 9001's [hub](https://github.com/9001/asm/blob/hovudstraum/p/hub/) ISO, except not alpine-based :sweat_smile:

## How to install
A single command:
```ShellSession
$ nix develop -c sudo disko-install -m format --flake .#<HOSTNAME> --disk main /dev/nvme0n1
```
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
## The hostnames

- `boomer`, a reasonably sluggish Ryzen 5 2600 desktop PC
- `commitit`, Hetzner bakkie for my own Forgejo instance
- `feather`, the ultra-light Thinkpad X1 Carbon G8
