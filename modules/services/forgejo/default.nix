# most of this is amalgamated from wiki.nixos.org pages
{
  flake.modules.nixos.services-forgejo =
    {
      pkgs,
      lib,
      config,
      inputs',
      ...
    }:
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

        iocaine = {
          enable = mkEnableOption "rerouting nginx thru iocaine first" // {
            default = true;
          };
          port = mkOption {
            description = "The port that iocaine runs on";
            default = 42069;
            type = port;
          };
          metricsPort = mkOption {
            description = "The port that iocaine runs its metrics on";
            default = 42042;
            type = port;
          };
        };
      };

      config = mkIf cfg.enable {
        services.openssh.enable = mkDefault true |> mkIf cfg.enableSsh;

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

            metrics.ENABLED = true;

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

        systemd.services.forgejo-dump.serviceConfig.ExecStart =
          let
            dumpCfg = config.services.forgejo.dump;
          in
          lib.mkForce (
            pkgs.writeShellScript "forgejo-dump-start" ''
              ${lib.getExe' config.services.forgejo.package "forgejo"} \
              dump \
              --type ${dumpCfg.type} \
              --skip-repo-archives \
              --skip-package-data
              chmod -R g+r /var/lib/forgejo/dump
            ''
          );

        # this map may or may not reroute GET and HEAD requests to iocaine,
        # depending on whether or not it's enabled. This allows me to proxy to
        # "$upstream_location" unconditionally below.
        services.nginx.commonHttpConfig =
          let
            inherit (cfg) httpPort;
            proxiedPort = if cfg.iocaine.enable then cfg.iocaine.port else cfg.httpPort;
          in
          ''
            map $request_method $upstream_location {
              GET      http://127.0.0.1:${toString proxiedPort};
              HEAD     http://127.0.0.1:${toString proxiedPort};
              default  http://127.0.0.1:${toString httpPort};
            }
          '';

        services.nginx.virtualHosts.${cfg.domain} = {
          forceSSL = true;
          enableACME = true;
          extraConfig = ''
            client_max_body_size 512M;
            recursive_error_pages on;
          '';
          locations = {
            "/" = {
              proxyPass = "$upstream_location";

              extraConfig = lib.optionalString cfg.iocaine.enable ''
                proxy_cache off;
                proxy_intercept_errors on;
                error_page 421 = @fallback;
              '';
            };
          }
          // lib.optionalAttrs cfg.iocaine.enable {
            "@fallback".proxyPass = "http://localhost:${toString cfg.httpPort}";
          };
        };

        services.iocaine = lib.mkIf cfg.iocaine.enable {
          enable = true;
          config = {
            handler.main.path = "${inputs'.nixocaine.packages.nam-shub-of-enki}";
            server = {
              default = {
                bind = "127.0.0.1:${toString cfg.iocaine.port}";
                mode = "http";
                use = {
                  handler-from = "main";
                  metrics = "metrics";
                };
              };
              metrics = {
                bind = "0.0.0.0:${toString cfg.iocaine.metricsPort}";
                mode = "prometheus";
                persist-path = "qmk-metrics.json";
                persist-interval = "1h";
              };
            };
          };
        };

        infra.monitoring.extraScrapeConfigs = {
          iocaine.port = cfg.iocaine.metricsPort;
          forgejo.port = cfg.httpPort;
        };
      };
    };
}
