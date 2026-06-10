{ lib, ... }:
let
  inherit (lib)
    mkIf
    mkEnableOption
    mkOption
    ;
  inherit (lib.types)
    str
    ;
in
{
  flake.modules.nixos.services-matrix =
    { config, pkgs, ... }:
    let
      cfg = config.infra.matrix;
    in
    {
      options.infra.matrix = {
        enable = mkEnableOption "continuwuity";
        fqdn = mkOption {
          description = "domain for the matrix identities";
          type = str;
          default = (import ../_consts.nix).domain;
        };
        domain = mkOption {
          description = "domain to host cinny on";
          type = str;
          default = "im.${(import ../_consts.nix).domain}";
        };
      };

      config = mkIf cfg.enable {
        services.matrix-continuwuity = {
          enable = true;
          settings.global = {
            server_name = cfg.fqdn;
            allow_registration = false;
            allow_encryption = true;
            allow_federation = true;
            allow_legacy_media = false;

            trusted_servers = [
              "matrix.org"
              "bartoostveen.nl"
              "utwente.io"
              "elisaado.nl"
              "koenoostveen.nl"
            ];

            address = null;
            unix_socket_path = "/run/continuwuity/continuwuity.sock";
            unix_socket_perms = 660;

            url_preview_domain_explicit_allowlist = [
              "i.imgur.com"
              "cdn.discordapp.com"
              "ooye.elisaado.com"
              "media.tenor.com"
              "giphy.com"
              "cdn.nest.rip"
              "ssd-cdn.nest.rip"
              "i.github.com"
              "github.com"
              "fs.omeduostuurcentenneef.nl"
              "files.bartoostveen.nl"
              "party.vitune.app"
              "fs.toostveen.nl"
            ];

            well_known = {
              client = "https://${cfg.domain}";
              server = "${cfg.domain}:443";
              support_mxid = "@tom:${cfg.fqdn}";
            };
          };
        };

        services.nginx.virtualHosts =
          let
            socket = "http://unix://${config.services.matrix-continuwuity.settings.global.unix_socket_path}";
          in
          {
            ${cfg.fqdn}.locations."/.well-known/matrix/".proxyPass = socket;
            ${cfg.domain} = {
              enableACME = true;
              forceSSL = true;

              locations = {
                "/".root = pkgs.cinny;
                "/_matrix".proxyPass = socket;
              };
            };
          };

        systemd.services.nginx.serviceConfig.SupplementaryGroups = [
          config.services.matrix-continuwuity.group
        ];
      };
    };
}
