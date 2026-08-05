{
  self,
  lib,
  inputs,
  ...
}:
{
  flake-inputs.nixvim = {
    url = "github:nix-community/nixvim";
    inputs.nixpkgs.follows = "nixpkgs";
    inputs.flake-parts.follows = "flake-parts";
  };

  imports = [ inputs.nixvim.flakeModules.default ];

  nixvim = {
    packages.enable = true;
    checks.enable = true;
  };

  flake.modules.nixvim.default.imports = lib.singleton self.modules.nixvim.minimal;

  perSystem =
    { system, ... }:
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
    };
}
