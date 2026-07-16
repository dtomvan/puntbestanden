{ inputs, lib, ... }:
let
  inherit (lib)
    mkEnableOption
    mkIf
    ;

  myOwnInfraModuleOnTop =
    { config, self', ... }:
    let
      cfg = config.infra.matrix.telegram;
      package = self'.legacyPackages.bart.mautrix-telegram-go;
    in
    {
      options.infra.matrix.telegram = {
        enable = mkEnableOption "Mautrix-Telegram, a Matrix-Telegram hybrid puppeting/relaybot bridge";
      };

      config = mkIf cfg.enable {
        environment.systemPackages = [ package ];

        services.mautrix-telegram-go = {
          enable = true;
          inherit package;
          setupPostgres = true;
          settings = {
            appservice = {
              id = "telegram";
              address = "http://localhost:29317";
              hostname = "127.0.0.1";
              port = 29317;

              async_transactions = false;

              bot = {
                avatar = "remove";
                displayname = "remove";
                username = "telegrambot";
              };

              ephemeral_events = true;
            };

            backfill.enabled = true;

            bridge = {
              permissions = {
                "*" = "relay";
                "@tom:toostveen.nl" = "admin";
                "toostveen.nl" = "user";
              };
            };

            direct_media.enabled = false;

            homeserver = {
              address = "https://${config.infra.matrix.domain}:443";
              domain = config.infra.matrix.fqdn;
              # MSC2246 https://forgejo.ellis.link/continuwuation/continuwuity/issues/880
              async_media = false;
              software = "standard";
            };

            matrix = {
              delivery_receipts = true;
              federate_rooms = false;
            };

            network.animated_sticker = {
              args = {
                fps = 25;
                height = 256;
                width = 256;
              };
              convert_from_webm = false;
              target = "png";
            };
            provisioning.shared_secret = "disable";
            public_media.enabled = false;
            env_config_prefix = "BRIDGE_";
          };

          environmentFile = config.sops.secrets.mautrix-telegram-go.path;
        };

        systemd.services.mautrix-telegram = {
          wants = [ "continuwuity.service" ];
          after = [ "continuwuity.service" ];
        };

        sops.secrets.mautrix-telegram-go = {
          sopsFile = ../../secrets/mautrix-telegram.${config.networking.hostName}.secret;
          owner = "mautrix-telegram";
          group = "mautrix-telegram";
          format = "binary";
        };
      };
    };
in
{
  flake-inputs = {
    bart = {
      url = "github:bartoostveen/infra";
      flake = false;
    };
    bart-packages = {
      url = "git+https://git.bartoostveen.nl/bart/nix-packages.git";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        treefmt-nix.follows = "treefmt-nix";
        flake-parts.follows = "flake-parts";
      };
    };
  };

  pkgs-config.permittedInsecurePackages = [ "olm-3.2.16" ];

  flake.modules.nixos.services-mautrix-telegram.imports = [
    "${inputs.bart}/modules/infra/mautrix-telegram-go.nix"
    myOwnInfraModuleOnTop
  ];

  perSystem = { inputs', ... }: {
    legacyPackages.bart = inputs'.bart-packages.legacyPackages;
  };
}
