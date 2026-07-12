{
  inputs,
  config,
  lib,
  self,
  ...
}:
let
  inherit (lib) mkOption;
  inherit (lib.types) listOf attrsOf raw;

  # HACK: only support x86_64-linux, because otherwise `nix flake show`
  # wouldn't work anymore... sigh...
  pkgs' = import inputs.nixpkgs { system = "x86_64-linux"; };
  nixpkgsPatched = pkgs'.applyPatches {
    name = "source";
    src = inputs.nixpkgs;
    patches = import ./_nixpkgs-patches.nix {
      inherit (pkgs') fetchpatch fetchpatch2;
    };
  };
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
    flake-inputs = {
      nixpkgs.url = "https://channels.nixos.org/nixos-unstable/nixexprs.tar.zst";
      nixos-small.url = "https://channels.nixos.org/nixos-unstable-small/nixexprs.tar.zst";

      nur = {
        url = "github:nix-community/NUR";
        inputs.nixpkgs.follows = "nixpkgs";
        inputs.flake-parts.follows = "flake-parts";
      };

      lazy-apps = {
        # my fork which adds "support" for devshells
        url = "git+https://git.toostveen.nl/tom/lazy-apps";
        inputs.nixpkgs.follows = "nixpkgs";
      };
    };

    perSystem =
      { pkgs, system, ... }:
      let
        nixpkgs = if system == "x86_64-linux" then nixpkgsPatched else inputs.nixpkgs;
      in
      {
        _module.args.pkgs = import nixpkgs {
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

        # copied from nixpkgs' flake.nix so I can redirect the base eval path
        # to the new nixpkgs. So that not only package definitions can see
        # patches, but also NixOS modules etc.
        legacyPackages.nixosSystem =
          args:
          import "${nixpkgs}/nixos/lib/eval-config.nix" (
            {
              inherit (pkgs) lib;
              system = null;
              modules = args.modules ++ [
                (self.lib.system system)
                {
                  nixpkgs.flake.source = nixpkgs.outPath;
                }
              ];
            }
            // removeAttrs args [ "modules" ]
          );
      };
  };
}
