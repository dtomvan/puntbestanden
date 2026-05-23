# most of this is amalgamated from wiki.nixos.org pages
{
  flake.modules.nixos.services-forgejo =
    { lib, config, ... }:
    let
      cfg = config.infra.fj;

      inherit (lib)
        mkDefault
        mkEnableOption
        mkIf
        mkOption
        ;

      inherit (lib.types) str port;
    in
    {
      options.infra.fj = {
        enable = mkEnableOption "forgejo";
        enableActions = mkEnableOption "Github actions on forgejo";
        enableSsh = mkEnableOption "Pushing thru SSH";

        domain = mkOption {
          description = "The domain to point fj and nginx to";
          type = str;
        };

        lfsSupport = mkEnableOption "LFS support";

        httpPort = mkOption {
          description = "The insecure fallback HTTP port";
          default = 3000;
          type = port;
        };
      };

      config = mkIf cfg.enable {
        services.openssh.enable = mkDefault true |> mkIf cfg.enableSsh;

        services.nginx = {
          virtualHosts.${cfg.domain} = {
            forceSSL = true;
            enableACME = true;
            extraConfig = ''
              client_max_body_size 512M;
            '';
            locations."/".proxyPass = "http://localhost:${toString cfg.httpPort}";
          };
        };

        services.forgejo = {
          enable = true;

          database.type = "postgres";
          lfs.enable = cfg.lfsSupport;

          dump = {
            enable = true;
            type = "tar.xz";
            age = "4w";
          };

          settings = {
            DEFAULT = {
              APP_NAME = "Smederij";
              APP_SLOGAN = "Voorbij programmeren, Wij Smeden.";
            };

            # reuse database for saving sessions so that after restarting forgejo your session is kept
            session.PROVIDER = "db";

            cron.ENABLED = true;

            server = {
              DOMAIN = cfg.domain;
              # You need to specify this to remove the port from URLs in the web UI.
              ROOT_URL = "https://${cfg.domain}/";
              HTTP_PORT = cfg.httpPort;
              SSH_PORT = lib.head config.services.openssh.ports |> mkIf cfg.enableSsh; # enable SSH authentication
            };

            repository.DISABLE_DOWNLOAD_SOURCE_ARCHIVES = mkDefault true;
          };
        };
      };
    };
}
