{
  self,
  inputs,
  config,
  lib,
  ...
}:
{
  options = {
    pkgs-overlays = lib.mkOption {
      type = with lib.types; listOf raw;
      default = [ ];
    };
    pkgs-config = lib.mkOption {
      type = with lib.types; attrsOf raw;
      default = { };
    };
  };

  config = {
    flake-file.inputs = {
      nur = {
        url = "github:nix-community/NUR";
        inputs.nixpkgs.follows = "nixpkgs";
      };
    };

    perSystem =
      { system, ... }:
      {
        _module.args.pkgs = import inputs.nixpkgs {
          inherit system;
          config = {
            allowUnfree = true;
          } // config.pkgs-config;
          overlays = [
            inputs.nur.overlays.default
            inputs.lazy-apps.overlays.default
            self.overlays.plasmashell-workaround # https://github.com/NixOS/nixpkgs/issues/126590
            (_final: _prev: self.packages.${system})
          ] ++ config.pkgs-overlays;
        };
      };
  };
}
