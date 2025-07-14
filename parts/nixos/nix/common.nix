{ config, inputs, ... }:
{
  flake.modules.nixos.nix-common =
    {
      pkgs,
      lib,
      ...
    }:
    {
      boot.kernelPackages = pkgs.linuxPackages_latest;

      nixpkgs.flake.setFlakeRegistry = true;
      nix = {
        settings = {
          experimental-features = lib.mkDefault [
            "nix-command"
            "flakes"
          ];
          connect-timeout = 5;
          min-free = 128 * 1000 * 1000;
          max-free = 1 * 1000 * 1000 * 1000;
          fallback = true;
          # TODO: consider these
          # keep-outputs = true;
          # keep-going = true;
          # keep-failed = true;
        } // config.flake.nixConfig;
        channel.enable = false;

        gc = {
          automatic = true;
          dates = "weekly";
          options = "--delete-older-than 14d";
        };

        optimise = {
          automatic = true;
        };

        registry =
          (lib.mapAttrs
            # WHY can't this be key as indirect reference name then value as
            # a path, DONE
            (name: value: {
              from = {
                type = "indirect";
                id = name;
              };
              flake = value;
            })
            {
              inherit (inputs)
                disko
                localsend-rs
                nixpkgs-unfree
                nur
                vs2nix
                ;
            }
          )
          // {
            # loosey goosey dependency, it's fine though. always pull the latest
            # one please!
            templates = {
              from = {
                type = "indirect";
                id = "templates";
              };
              to = {
                owner = "dtomvan";
                repo = "templates";
                type = "github";
              };
            };
          };
      };

      boot.tmp.cleanOnBoot = true;

      services.journald.extraConfig = ''
        SystemMaxUse=250M
        SystemMaxFileSize=50M
      '';

      networking = {
        networkmanager.enable = true;
      };

      sops.age.sshKeyPaths = [
        "/etc/ssh/ssh_host_ed25519_key"
        "/home/tomvd/.ssh/id_ed25519"
      ];

      # fix: nixos/nixpkgs#413937
      environment.variables.WEBKIT_DISABLE_DMABUF_RENDERER = 1;
    };
}
