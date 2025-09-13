{ inputs, ... }:
let
  catppuccin = {
    accent = "peach";
    flavor = "mocha";
  };
in
{
  nixConfig = {
    extra-substituters = [ "https://catppuccin.cachix.org" ];
    extra-trusted-public-keys = [
      "catppuccin.cachix.org-1:noG/4HkbhJb+lUAdKrph6LaozJvAeEEZj4N732IysmU="
    ];
  };

  flake-file.inputs.catppuccin = {
    url = "github:catppuccin/nix";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake.modules.nixos.profiles-catppuccin = {
    imports = [
      inputs.catppuccin.nixosModules.catppuccin
    ];

    catppuccin = catppuccin // {
      sddm.enable = true;
    };
  };

  flake.modules.homeManager.profiles-catppuccin = {
    imports = [
      inputs.catppuccin.homeModules.catppuccin
    ];

    catppuccin = catppuccin // {
      alacritty.enable = true;
      bat.enable = true;
      btop.enable = true;
      glamour.enable = true;
      skim.enable = true;
      yazi.enable = true;
      zellij.enable = true;
    };
  };
}
