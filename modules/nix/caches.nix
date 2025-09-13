{ lib, config, ... }:
{
  options.nixConfig = lib.mkOption {
    description = "caches to be passed to the flake's nixConfig and to nixos' nix.settings";
    type = with lib.types; attrsOf (listOf str);
    default = { };
  };

  config = {
    nixConfig = {
      extra-substituters = [
        "https://nix-community.cachix.org"
        "https://cache.garnix.io"
      ];

      extra-trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
      ];
    };

    flake-file = { inherit (config) nixConfig; };
    flake.modules.nixos.nix-common = {
      nix = {
        settings = config.nixConfig;
      };
    };
  };
}
