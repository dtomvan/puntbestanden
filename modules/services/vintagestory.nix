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
              mods:
              with mods;
              [
                # betterruins
                (pkgs.fetchurl rec {
                  pname = "BetterRuins";
                  version = "0.4.14";
                  url = "https://mods.vintagestory.at/download/46364/${pname}v${version}.zip";
                  hash = "sha256-aDFrBa1pN0gc0SpuiMynO19L4BCbogtBpKtFnao+G8w=";
                })
                # settings:
                # landform 50%, lf scale 300%
                # worldheight 320
                terraprety
                # needed for terraprety above 1.20
                (pkgs.fetchurl rec {
                  pname = "MoreBlueClay";
                  version = "1.0.1";
                  url = "https://mods.vintagestory.at/download/35368/${pname}_${version}.zip";
                  hash = "sha256-eQIV5NHTHleAaPWPi9m9RQbJaZDkT89/kqjFU6BicU8=";
                })
                (pkgs.fetchurl rec {
                  pname = "BetterForest";
                  version = "0.1.0";
                  url = "https://mods.vintagestory.at/download/33287/${pname}_${version}.zip";
                  hash = "sha256-1q166al70H7WwB2irzngVI4s37NI1MvqqKKyRiBZ80A=";
                })
                # more survival mechanics
                primitivesurvival

                ## QOL
                betterfirepit
                carryon
                gimmeoneseedplz
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
              ++ lib.optionals (lib.versionOlder pkgs.vintagestory.version "1.21") [
                # needed for terraprety below 1.21
                (pkgs.fetchurl rec {
                  pname = "SeaLevelFix";
                  version = "1.0.11";
                  url = "https://mods.vintagestory.at/download/45783/${pname}_${version}.zip";
                  hash = "sha256-2GthrtRefpHYTDsoL2sNnvlUUQXzwMymfNyh4PRI03s=";
                })
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
}
