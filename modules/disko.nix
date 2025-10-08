{ inputs, ... }:
{
  flake-file.inputs = {
    disko = {
      url = "github:nix-community/disko/latest";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  flake.modules.nixos.profiles-base = {
    imports = [
      inputs.disko.nixosModules.disko
      # TODO: uncomment after moving all of my machines to disko
      # ./community/autounattend/_disko.nix
    ];
  };

  perSystem =
    { pkgs, ... }:
    {
      devshells.default.packages = with pkgs; [ disko ];
    };

  text.readme.parts.disko_install = ''

## How to install
A single command: 
```ShellSession
$ nix develop -c sudo disko-install -m format --flake .#<HOSTNAME> --disk main /dev/nvme0n1
```
  '';
}
