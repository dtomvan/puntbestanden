toplevel@{ self, lib, ... }:
let
  inherit (builtins)
    attrValues
    filter
    ;

  inherit (lib)
    mkOption
    mkIf
    mkEnableOption
    mkForce
    ;
  inherit (lib.types) str;

  inherit (import ../../_consts.nix) domain;
in
{
  flake.modules.nixos.services-alertmanager =
    { config, pkgs, ... }:
    let
      cfg = config.infra.monitoring.alertmanager;
    in
    {
      options.infra.monitoring.alertmanager = {
        enable = mkEnableOption "alertmanager";

        matrix = {
          enable = mkEnableOption "alertmanager-matrix" // {
            default = true;
          };

          room = mkOption {
            type = str;
            default = "!D1UGkCXd6fNR07dcxGOiPEtHQPA1C7OBbZeM8ywoTyE";
          };

          homeserver = mkOption {
            type = str;
            default = "https://im.${domain}";
          };

          userId = mkOption {
            type = str;
            default = "@alertmanager:toostveen.nl";
          };
        };
      };

      config = mkIf cfg.enable {
        sops.secrets.alertmanager-matrix-token = {
          mode = "0400";
          sopsFile = ../../../secrets/alertmanager-matrix-token.secret;
          format = "binary";
          owner = config.systemd.services.alertmanager-matrix.serviceConfig.User;
          group = config.systemd.services.alertmanager-matrix.serviceConfig.Group;
        };

        users.users.alertmanager-matrix = {
          isSystemUser = true;
          group = "alertmanager-matrix";
        };
        users.groups.alertmanager-matrix = { };

        system.services.alertmanager-matrix = mkIf cfg.matrix.enable {
          _class = "service";
          imports = [ pkgs.nur.repos.dtomvan.alertmanager-matrix.services.default ];
          alertmanager-matrix = {
            inherit (cfg.matrix) homeserver userId;

            tokenFile = config.sops.secrets.alertmanager-matrix-token.path;
            alertmanager = "http://localhost:${toString config.services.prometheus.alertmanager.port}";
            logLevel = "debug";
          };

          systemd.service.serviceConfig = {
            User = "alertmanager-matrix";
            Group = "alertmanager-matrix";
            DynamicUser = mkForce false;
          };
        };

        services.prometheus.alertmanager = {
          enable = true;
          configuration = {
            receivers = lib.optionals cfg.matrix.enable [
              {
                name = "matrix";
                webhook_configs = [
                  { url = "http://localhost:4051/${cfg.matrix.room}"; }
                ];
              }
            ];

            route.receiver =
              if cfg.matrix.enable then "matrix" else (throw "I haven't made up a seperate alerting path yet");
          };
        };

        services.prometheus.alertmanagers = [
          {
            scheme = "http";
            static_configs = [
              {
                targets =
                  toplevel.config.hosts
                  |> attrValues
                  |> filter (h: h.networking.wireguard.enable)
                  |> (map (
                    h:
                    let
                      inherit (h.networking) hostName;
                      inherit (self.nixosConfigurations.${hostName}) config;
                    in
                    "${hostName}:${toString config.services.prometheus.alertmanager.port}"
                  ));
              }
            ];
          }
        ];
      };
    };
}
