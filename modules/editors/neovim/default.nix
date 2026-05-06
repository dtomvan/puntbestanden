{
  self,
  lib,
  inputs,
  ...
}:
{
  flake-file.inputs = {
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  imports = [ inputs.nixvim.flakeModules.default ];

  nixvim = {
    packages.enable = true;
    checks.enable = true;
  };

  flake.modules.nixvim.default.imports = lib.singleton self.modules.nixvim.minimal;

  perSystem =
    {
      self',
      system,
      ...
    }:
    {
      nixvimConfigurations = {
        nixvim = inputs.nixvim.lib.evalNixvim {
          inherit system;
          modules = [
            self.modules.nixvim.default
            (self.lib.system system)
          ];
        };
        nixvim-minimal = inputs.nixvim.lib.evalNixvim {
          inherit system;
          modules = [
            self.modules.nixvim.minimal
            (self.lib.system system)
          ];
        };
      };

      packages.activatable-nixvim = self'.legacyPackages.activationPackage {
        profile = self'.packages.nixvim.overrideAttrs { dontFixup = true; };
        profileName = "nixvim";
        priority = 4; # ahead of default priority, so home-manager can also install neovim without both colliding
      };

      apps.nixvim-activate = {
        type = "app";
        meta.description = "Activate your Nixvim configuration";
        program = lib.getExe' self'.packages.activatable-nixvim "activate";
      };
    };
}
