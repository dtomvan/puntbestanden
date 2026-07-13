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
          lib.optionalString cfg.iocaine.enable ''
            map $request_method $forgejo_upstream_location {
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
              proxyPass = "$forgejo_upstream_location";

              extraConfig = lib.optionalString cfg.iocaine.enable ''
                proxy_cache off;
                proxy_intercept_errors on;
                error_page 421 = @fallback;
                access_log off;
              '';
            };
          }
          // lib.optionalAttrs cfg.iocaine.enable {
            "@fallback".proxyPass = "http://localhost:${toString cfg.httpPort}";
          };
        };

        environment.etc."systemd/journald@iocaine.conf".text = ''
          [Journal]
          SystemMaxUse=1G
        '';

        systemd.services.iocaine.serviceConfig.LogNamespace = "iocaine";

        # TODO: factor out into seperate iocaine module
        services.iocaine = lib.mkIf cfg.iocaine.enable {
          enable = true;
          config = {
            initial-seed-file = "/run/current-system/boot.json";

            handler.main = {
              path = "${inputs'.nixocaine.packages.nam-shub-of-enki}";
              config = {
                inherits = "recommended";
                # very random, yes
                logging.classification.enable = true;
                sources = {
                  wordlists =
                    pkgs.fetchurl {
                      url = "https://cgit.git.savannah.gnu.org/cgit/miscfiles.git/plain/web2?id=fc51530ea66019efba9e961578df986a950cbb65";
                      hash = "sha256-KSmJWrP+x4xpY+vly7NJP+T8nhHroJWlInh7ivxTqGM=";
                    }
                    |> lib.singleton;

                  training-corpus = [
                    (pkgs.fetchurl {
                      url = "https://archive.org/download/GeorgeOrwells1984/1984_djvu.txt";
                      hash = "sha256-9R1PTa8yDtkfH+4rU5BF62ee73irhd3VYX1QB5KU+ZU=";
                    })
                    (pkgs.fetchurl {
                      url = "https://archive.org/download/ost-english-brave_new_world_aldous_huxley/Brave_New_World_Aldous_Huxley_djvu.txt";
                      hash = "sha256-6WkaO/3zQIezGzJDp4QjglikiTZTxgo0P4MEff2mdcY=";
                    })
                  ];
                };
                checks = {
                  anti_robots_txt.enable = true; # blocklist for specific bots that are known to not respect your robots.txt
                  browser_verification.enable = false; # seems to trip up some old browsers, and also vivaldi
                  commercial_scrapers.enable = true;
                  cookie_monster = {
                    enable = true;
                    forgejo_hosts = [ cfg.domain ];
                    forgejo_challenge = "automatic";
                  };
                  firefox_ai.enable = true; # no thanks
                  generated_urls = {
                    enable = true;
                    identifiers = [ "clanker_mode" ]; # default is a dot, which isn't a good idea
                  };
                };
              };
            };
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
