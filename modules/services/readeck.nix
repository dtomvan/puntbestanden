{
  flake.modules.nixos.services-readeck =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    let
      cfg = config.infra.readeck;
      inherit (lib)
        types
        mkEnableOption
        mkPackageOption
        mkOption
        mkIf
        ;
      inherit (types) str port nullOr;
    in
    {
      options.infra.readeck = {
        enable = mkEnableOption "readeck";
        package = mkPackageOption pkgs "readeck" { };

        readeckPort = mkOption {
          type = port;
          default = 24464;
        };

        domain = mkOption {
          type = str;
          default = "rd.${(import ../_consts.nix).domain}";
        };

        environmentFile = mkOption {
          type = nullOr str;
          default = config.sops.secrets.readeck.path;
        };
      };

      config = {
        sops.secrets.readeck = {
          sopsFile = ../../secrets/readeck.secret;
          format = "binary";
          mode = "400";
        };

        services.readeck = {
          inherit (cfg) enable package environmentFile;

          settings.server = {
            port = cfg.readeckPort;
            host = "127.0.0.1";
          };
        };

        services.nginx.virtualHosts."${cfg.domain}" = mkIf cfg.enable {
          enableACME = true;
          forceSSL = true;
          locations."/".proxyPass = "http://127.0.0.1:${toString cfg.readeckPort}";
        };
      };
    };

  flake.modules.homeManager.firefox = { pkgs, ... }: {
    programs.firefox.profiles.dev-edition-default.extensions.packages = [
      pkgs.nur.repos.rycee.firefox-addons.readeck
    ];
  };
}
