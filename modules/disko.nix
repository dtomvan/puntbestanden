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
}
