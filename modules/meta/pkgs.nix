{
  inputs,
  config,
  lib,
  ...
}:
let
  inherit (lib) mkOption;
  inherit (lib.types) listOf attrsOf raw;
in
{
  options = {
    pkgs-overlays = mkOption {
      type = listOf raw;
      default = [ ];
    };
    pkgs-config = mkOption {
      type = attrsOf raw;
      default = { };
    };
  };

  config = {
    flake-file.inputs = {
      # nixpkgs.url = "https://channels.nixos.org/nixos-unstable/nixexprs.tar.xz";
      nixpkgs-patcher = {
        url = "github:dtomvan/nixpkgs-patcher";

        # disable all irrelevant inputs here since I only care about the
        # "resulting" nixpkgs-patched output
        inputs.nixpkgs.follows = "";
        inputs.systems.follows = "";
        inputs.flake-parts.follows = "";
        inputs.nix-patcher.follows = "";
      };
      # accepts nixpkgs from the flake.nix in nixpkgs-patcher...
      # HACK: this fixes an oversight where nixpkgs would lag behind if no patches are currently applied.
      # TASK(20260501-093130): maybe incorporate the patcher in a subflake in
      # this tree so there's a SSOT for what nixpkgs I pull in?
      nixpkgs.follows = "nixpkgs-patcher/nixpkgs-patched";
      nixos-small.url = "github:nixos/nixpkgs/nixos-unstable-small";

      nur = {
        url = "github:nix-community/NUR";
        inputs.nixpkgs.follows = "nixpkgs";
      };

      lazy-apps = {
        # my fork which adds "support" for devshells
        url = "github:dtomvan/lazy-apps";
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
          }
          // config.pkgs-config;
          overlays = [
            inputs.nur.overlays.default
            inputs.lazy-apps.overlays.default
          ]
          ++ config.pkgs-overlays;
        };
      };
  };
}
