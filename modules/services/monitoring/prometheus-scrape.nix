toplevel@{ self, lib, ... }:
let
  inherit (builtins)
    attrNames
    attrValues
    concatLists
    elemAt
    filter
    tryEval
    ;

  inherit (lib)
    uniqueStrings
    singleton
    mkOption
    mkIf
    mkEnableOption
    mkMerge
    ;
  inherit (lib.types) str;

  inherit (import ../../_consts.nix) domain;
in
{
  flake.modules.nixos.services-monitoring =
    { config, ... }:
    let
      cfg = config.infra.monitoring.prometheus;
    in
    {
      options.infra.monitoring.prometheus = {
        enable = mkEnableOption "prometheus";
        domain = mkOption {
          type = str;
          default = "prometheus.${domain}";
        };
      };

      config = mkMerge [
        {
          sops.secrets.prometheus-http-config = {
            mode = "0440";
            sopsFile = ../../../secrets/prometheus-http-config.secret;
            format = "binary";
            owner = "prometheus";
            group = "prometheus";
          };
        }
        (mkIf cfg.enable {
          services.nginx.virtualHosts = {
            ${cfg.domain} = {
              forceSSL = true;
              enableACME = true;
              locations."/" = {
                proxyPass = "http://${config.services.prometheus.listenAddress}:${toString config.services.prometheus.port}";
                proxyWebsockets = true;
                recommendedProxySettings = true;
              };
            };
          };

          services.prometheus = {
            enable = true;
            enableReload = true;
            webExternalUrl = "https://${cfg.domain}";
            webConfigFile = config.sops.secrets.prometheus-http-config.path;
            scrapeConfigs =
              let
                hostsOnWireguard = toplevel.config.hosts |> attrValues |> filter (h: h.networking.wireguard.enable);

                exportersOnWireguard =
                  config.services.prometheus.exporters
                  |> attrNames
                  |> map (name: {
                    job_name = name;
                    static_configs = singleton {
                      targets =
                        hostsOnWireguard
                        |> filter (
                          h:
                          let
                            inherit (h.networking) hostName;
                            thisConfig = self.nixosConfigurations.${hostName}.config.services.prometheus.exporters.${name};
                            e = tryEval (thisConfig ? enable && thisConfig.enable);
                          in
                          e.success && e.value
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

                extraJobNames =
                  hostsOnWireguard
                  |> map (h: h.extraScrapeConfigs |> attrNames)
                  |> concatLists
                  |> uniqueStrings;

                extrasOnWireguard =
                  extraJobNames
                  |> map (name: {
                    job_name = name;
                    static_configs = singleton {
                      targets =
                        hostsOnWireguard
                        |> filter (h: h.extraScrapeConfigs ? name)
                        |> map (h: "${h.networking.hostName}:${toString h.extraScrapeConfigs.${name}.port}");
                    };
                  });
              in
              exportersOnWireguard ++ extrasOnWireguard;
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
              attrValues {
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
