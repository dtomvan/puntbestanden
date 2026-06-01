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
  };

  imports = [ inputs.nixvim.flakeModules.default ];

  nixvim = {
    packages.enable = true;
    checks.enable = true;
  };

  flake.modules.nixvim.default.imports = lib.singleton self.modules.nixvim.minimal;

  perSystem =
    { pkgs, system, ... }:
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

      packages.nixvim-activate = pkgs.writeShellApplication {
        name = "nixvim-activate";
        runtimeInputs = [ pkgs.coreutils ];
        text = ''
          profileAttr="${../../..}#deploy.nodes.$(hostname).profiles.nixvim-$(whoami).path"

          activator="$(nix build \
            --print-out-paths \
            --no-link \
            "$profileAttr")"

          PROFILE="$(nix build \
            --print-out-paths \
            --no-link \
            "$profileAttr.base")"

          export PROFILE

          "$activator/bin/deploy-rs-activate" activate
        '';
        meta.description = "Activate your Nixvim configuration";
      };
    };
}
