{
  inputs,
  flake-parts-lib,
  lib,
  ...
}:
let
  sopsSubmodule.options = {
    keys = lib.mkOption {
      type = with lib.types; attrsOf str;
      default = { };
    };

    creation_rules = lib.mkOption {
      type = with lib.types; attrsOf (listOf str);
      default = { };
    };
  };
in
{
  options = {
    flake = flake-parts-lib.mkSubmoduleOptions {
      sopsConfig = lib.mkOption {
        type = lib.types.submodule sopsSubmodule;
      };
    };
  };

  config = {
    flake-file.inputs = {
      sops = {
        url = "github:Mic92/sops-nix";
        inputs.nixpkgs.follows = "nixpkgs";
      };
    };

    flake.modules.nixos.sops = {
      imports = [
        inputs.sops.nixosModules.sops
      ];

      sops.age.sshKeyPaths = [
        "/etc/ssh/ssh_host_ed25519_key"
        "/home/tomvd/.ssh/id_ed25519"
      ];
    };

    flake.sopsConfig.creation_rules = {
      "secrets/[^/]+.secret" = [
        "boomer"
        "feather"
        "kaput"
      ];
    };

    perSystem =
      { pkgs, ... }:
      {
        devshells.default.packages = with pkgs; [
          age
          sops
          ssh-to-age
        ];
      };
  };
}
