toplevel@{ lib, ... }:
let
  inherit (import ../_consts.nix) domain;
  inherit (builtins) attrValues filter;
  inherit (lib)
    mkOption
    mkEnableOption
    mkIf
    mkMerge
    mkDefault
    singleton
    ;
  inherit (lib.types)
    attrs
    str
    listOf
    package
    ;

  nodeExporterPort = 9100;
in
{
  flake.modules.nixos.prometheus-node-exporter =
    { host, ... }:
    {
      assertions = [
        {
          assertion = host.prometheus.exportNode -> host.networking.wireguard.enable;
          message = "You need to have wireguard enabled in order for prometheus-node-exporter to work";
        }
      ];

      services.prometheus.exporters.node = mkIf host.prometheus.exportNode {
        enable = true;
        port = nodeExporterPort;
        disabledCollectors = [ "textfile" ];
        openFirewall = true;
        firewallFilter = "-i wg0 -p tcp -m tcp --dport ${toString nodeExporterPort}";
      };
    };

  flake.modules.nixos.services-monitoring =
    { pkgs, config, ... }:
    let
      cfg = config.infra.monitoring;
    in
    {
      options.infra.monitoring = {
        enable = mkEnableOption "prometheus and grafana";

        grafana = {
          domain = mkOption {
            type = str;
            default = "grafana.${domain}";
          };
          dashboards = mkOption {
            type = listOf package;
            default = singleton (
              pkgs.fetchurl {
                name = "prometheus-node-exporter.json";
                url = "https://grafana.com/api/dashboards/1860/revisions/45/download";
                hash = "sha256-GExrdAnzBtp1Ul13cvcZRbEM6iOtFrXXjEaY6g6lGYY=";
              }
            );
          };
          secretKeyFile = mkOption {
            type = str;
            default = config.sops.secrets.grafana-default-key.path;
          };
        };

        prometheus = {
          domain = mkOption {
            type = str;
            default = "prometheus.${domain}";
          };
        };

        admin = {
          username = mkOption {
            type = str;
            default = "admin";
          };
          email = mkOption {
            type = str;
            default = toplevel.config.users.tomvd.email;
          };
          passwordFile = mkOption {
            type = str;
            default = config.sops.secrets.grafana-default-password.path;
          };
        };
      };

      # HACK: prometheus-http-config has to correspond to grafana-default-password... sigh
      config = mkMerge [
        {
          sops.secrets.grafana-default-password = {
            mode = "0440";
            sopsFile = ../../secrets/grafana-default-password.secret;
            format = "binary";
            owner = "grafana";
            group = "nginx";
          };

          sops.secrets.grafana-default-key = {
            mode = "0440";
            sopsFile = ../../secrets/grafana-default-key.secret;
            format = "binary";
            owner = "grafana";
            group = "grafana";
          };

          sops.secrets.prometheus-http-config = {
            mode = "0440";
            sopsFile = ../../secrets/prometheus-http-config.secret;
            format = "binary";
            owner = "prometheus";
            group = "prometheus";
          };
        }

        (mkIf cfg.enable {
          services.nginx.virtualHosts = {
            ${cfg.grafana.domain} = {
              forceSSL = true;
              enableACME = true;
              locations."/" = {
                proxyPass = "http://unix://${toString config.services.grafana.settings.server.socket}";
                proxyWebsockets = true;
                recommendedProxySettings = true;
              };
            };

            ${cfg.prometheus.domain} = {
              forceSSL = true;
              enableACME = true;
              locations."/" = {
                proxyPass = "http://${config.services.prometheus.listenAddress}:${toString config.services.prometheus.port}";
                proxyWebsockets = true;
                recommendedProxySettings = true;
              };
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

              # TODO: postgres?

              security = {
                admin_user = cfg.admin.username;
                admin_email = cfg.admin.email;
                admin_password = "$__file{${cfg.admin.passwordFile}}";
                secret_key = "$__file{${cfg.grafana.secretKeyFile}}";
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
                basicAuthUser = cfg.admin.username;
                secureJsonData.basicAuthPassword = "$__file{${cfg.admin.passwordFile}}";
              };

              dashboards.settings.providers = [
                {
                  name = "Nix dashboards";
                  disableDeletion = true;
                  options = {
                    path = pkgs.linkFarmFromDrvs "grafana-dashboards" cfg.grafana.dashboards;
                    foldersFromFilesStructure = true;
                  };
                }
              ];
            };
          };

          services.prometheus = {
            enable = true;
            enableReload = true;
            webExternalUrl = "https://${cfg.prometheus.domain}";
            webConfigFile = config.sops.secrets.prometheus-http-config.path;
            scrapeConfigs = singleton {
              job_name = "node";
              static_configs =
                toplevel.config.hosts
                |> attrValues
                |> filter (h: h.prometheus.exportNode)
                |> map (h: {
                  targets = singleton "${h.networking.hostName}:${toString nodeExporterPort}";
                });
            };
          };
        })
      ];
    };

  perSystem =
    { pkgs, ... }:
    {
      packages.genprompw =
        pkgs.writers.writePython3Bin "genprompw"
          {
            libraries =
              p:
              builtins.attrValues {
                inherit (p) bcrypt;
              };
          }
          # python
          ''
            import getpass
            import bcrypt

            password = getpass.getpass("password: ")
            hashed_password = bcrypt.hashpw(password.encode("utf-8"), bcrypt.gensalt())
            print(hashed_password.decode())
          '';
    };
}
