toplevel@{ self, lib, ... }:
let
  inherit (import ../_consts.nix) domain;
  inherit (builtins)
    attrNames
    attrValues
    elemAt
    filter
    tryEval
    ;
  inherit (lib)
    mkOption
    mkEnableOption
    mkIf
    mkMerge
    mkDefault
    singleton
    ;
  inherit (lib.types)
    str
    listOf
    package
    ;
in
{
  flake.modules.nixos.services-monitoring =
    {
      pkgs,
      config,
      ...
    }:
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
            scrapeConfigs =
              config.services.prometheus.exporters
              |> attrNames
              |> map (name: {
                job_name = name;
                static_configs = singleton {
                  targets =
                    toplevel.config.hosts
                    |> attrValues
                    |> filter (
                      h:
                      let
                        inherit (h.networking) hostName;
                        wgEnable = h.networking.wireguard.enable;
                        thisConfig = self.nixosConfigurations.${hostName}.config.services.prometheus.exporters.${name};
                        e = tryEval (thisConfig ? enable && thisConfig.enable);
                      in
                      wgEnable && e.success && e.value
                    )
                    |> map (
                      h:
                      let
                        inherit (h.networking) hostName;
                        thisConfig = self.nixosConfigurations.${hostName}.config.services.prometheus.exporters.${name};
                      in
                      "${hostName}:${toString thisConfig.port}"
                    );
                };
              })
              |> filter (job: elemAt job.static_configs 0 |> (sc: sc.targets != [ ]));
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
