{ inputs, ... }:
{
  flake-file.inputs = {
    vs2nix = {
      url = "github:dtomvan/vs2nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  pkgs-overlays = [
    inputs.vs2nix.overlay
  ];

  flake.modules.nixos.services-vintagestory =
    {
      lib,
      config,
      pkgs,
      ...
    }:
    let
      host = "127.0.0.1";
      port = 42420;
    in
    {
      imports = [ inputs.vs2nix.nixosModules.default ];

      environment.systemPackages = with pkgs; [ rustique ];

      services.vintagestory = {
        enable = true;
        inherit host port;
        extraFlags = [
          "--addModPath"
          (builtins.toString (
            inputs.vs2nix.legacyPackages.x86_64-linux.makeVintageStoryModsDir "my-mods" (
              mods: with mods; [
                (pkgs.fetchurl rec {
                  pname = "BetterForest";
                  version = "0.1.1.zip";
                  url = "https://mods.vintagestory.at/download/52350/${pname}_${version}";
                  hash = "sha256-WAeWmP0s44NdD04w3z/E0WE+4eOXXJYfIcwX6AX7QbE=";
                })
                # more survival mechanics
                # primitivesurvival
                # TODO: remove after vs2nix bump
                (pkgs.fetchurl rec {
                  pname = "primitivesurvival";
                  version = "3.9.6.zip";
                  url = "https://mods.vintagestory.at/download/55364/${pname}_${version}";
                  hash = "sha256-THhLZjlRDY0lOXhB+xPb0kRBsnELsl1QxwGJHLgsQfY=";
                })

                ## QOL
                betterfirepit
                carryon
                justanarrowheadmold
                morepiles
                playercorpse
                prospecttogether

                ## Visual
                hit
                # Like MC's distant horizons
                farseer

                ## Libs
                commonlib
                vsimgui
                configlib
                autoconfiglib
              ]
            )
          ))
        ];
      };

      # takes up a bunch of memory, I'll start it on-demand
      systemd.services.vintagestory.wantedBy = lib.mkForce [ ];

      services.rathole = {
        enable = true;
        role = "client";
        settings.client = {
          remote_addr = "vitune.app:2333";
          services.vintagestory.local_addr = "${host}:${builtins.toString port}";
          transport.type = "noise";
        };
        credentialsFile = config.sops.secrets.rathole-client.path;
      };

      sops.secrets.rathole-client = {
        mode = "0444";
        format = "binary";
        sopsFile = ../../secrets/vitune/rathole-client.secret;
        restartUnits = [ "rathole.service" ];
      };
    };

  flake.sopsConfig = {
    keys.vitune = "age1tfcfat3y9uekdw8u2ln4az4uqfznk25ntarte34292rz0zw3zy6qjcqqth";
    creation_rules = {
      "secrets/vitune/rathole-server.secret" = [
        "vitune"
      ];

      "secrets/vitune/rathole-client.secret" = [
        "boomer"
      ];
    };
  };
}
