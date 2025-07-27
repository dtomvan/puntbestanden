{
  config,
  inputs,
  flake-parts-lib,
  lib,
  ...
}:
let
  sopsConfig = {
    # TODO: I think this can be done with the "apply" arg for mkOption?
    keys = lib.pipe config.flake.sopsConfig.keys [
      (lib.mapAttrs' (n: v: lib.nameValuePair "&${n}" v))
      lib.attrsToList
      (lib.map (k: "${k.name} ${k.value}"))
    ];

    # - prepend a star to the key name
    # - map it to a list
    # - fit it into a format sops likes
    creation_rules = lib.pipe config.flake.sopsConfig.creation_rules [
      (lib.mapAttrs (_k: lib.map (k: "*${k}")))
      lib.attrsToList
      (lib.map (rule: {
        path_regex = rule.name;
        key_groups = [
          { age = rule.value; }
        ];
      }))
    ];
  };

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
        # TODO: doesn't serialize correctly
        # files.files = [
        #   {
        #     path_ = ".sops.yaml";
        #     drv = pkgs.writers.writeYAML ".sops.yaml" sopsConfig;
        #   }
        # ];

        devshells.default.packages = with pkgs; [
          age
          sops
          ssh-to-age
        ];
      };
  };
}
