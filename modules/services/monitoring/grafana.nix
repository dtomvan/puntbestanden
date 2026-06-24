{
  flake.modules.nixos.services-monitoring =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    let
      inherit (lib)
        mkDefault
        mkOption
        mkEnableOption
        mkMerge
        mkIf
        singleton
        ;
      inherit (lib.types) listOf package str;

      inherit (import ../../_consts.nix) domain;
      cfg = config.infra.monitoring.grafana;
      adm = config.infra.monitoring.admin;
    in
    {
      options.infra.monitoring.grafana = {
        enable = mkEnableOption "grafana";
        domain = mkOption {
          type = str;
          default = "grafana.${domain}";
        };
        dashboards = mkOption {
          type = listOf package;
          default = [
            (pkgs.fetchurl {
              name = "prometheus-node-exporter.json";
              url = "https://grafana.com/api/dashboards/1860/revisions/45/download";
              hash = "sha256-GExrdAnzBtp1Ul13cvcZRbEM6iOtFrXXjEaY6g6lGYY=";
            })
            ./grafana-nginx-dashboard.json
          ];
        };
        secretKeyFile = mkOption {
          type = str;
          default = config.sops.secrets.grafana-default-key.path;
        };
      };

      # HACK: prometheus-http-config has to correspond to grafana-default-password... sigh
      config = mkMerge [
        {
          # unconditionally set grafana user cause otherwise sops-install-secrets would fail
          users.users.grafana = {
            isSystemUser = true;
            group = "grafana";
          };
          users.groups.grafana = { };

          sops.secrets.grafana-default-password = {
            mode = "0440";
            sopsFile = ../../../secrets/grafana-default-password.secret;
            format = "binary";
            owner = "grafana";
            group = "nginx";
          };

          sops.secrets.grafana-default-key = {
            mode = "0440";
            sopsFile = ../../../secrets/grafana-default-key.secret;
            format = "binary";
            owner = "grafana";
            group = "grafana";
          };
        }

        (mkIf cfg.enable {
          services.nginx.virtualHosts.${cfg.domain} = {
            forceSSL = true;
            enableACME = true;
            locations."/" = {
              proxyPass = "http://unix://${toString config.services.grafana.settings.server.socket}";
              proxyWebsockets = true;
              recommendedProxySettings = true;
            };
          };

          users.users.grafana.extraGroups = [ "nginx" ];

          services.grafana = {
            enable = true;
            settings = {
              server = {
                protocol = "socket";
                socket_gid = config.users.groups.nginx.gid;
                enforce_domain = true;
                enable_gzip = true;
                domain = "grafana.${domain}";
              };

              security = {
                admin_user = adm.username;
                admin_email = adm.email;
                admin_password = "$__file{${adm.passwordFile}}";
                secret_key = "$__file{${cfg.secretKeyFile}}";
                disable_gravatar = mkDefault true;
              };

              analytics.reporting_enabled = false;
            };

            provision = {
              enable = true;
              datasources.settings.datasources = singleton {
                name = "Prometheus";
                type = "prometheus";
                url = "http://${config.services.prometheus.listenAddress}:${toString config.services.prometheus.port}";
                isDefault = true;
                editable = false;
                basicAuth = true;
                basicAuthUser = adm.username;
                secureJsonData.basicAuthPassword = "$__file{${adm.passwordFile}}";
              };

              dashboards.settings.providers = singleton {
                name = "Nix dashboards";
                disableDeletion = true;
                options = {
                  path = pkgs.linkFarmFromDrvs "grafana-dashboards" cfg.dashboards;
                  foldersFromFilesStructure = true;
                };
              };
            };
          };

        })
      ];
    };
}
