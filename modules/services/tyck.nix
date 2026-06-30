{
  flake.modules.nixos.services-tyck =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    let
      cfg = config.services.tyck;
      inherit (lib)
        types
        mkEnableOption
        mkPackageOption
        mkOption
        mkIf
        getExe'
        ;
      inherit (types) str port nullOr;
    in
    {
      options.services.tyck = {
        enable = mkEnableOption "the tyck comments system for static blogs";
        package = mkPackageOption pkgs "tyck" {
          default = [
            "nur"
            "repos"
            "dtomvan"
            "tyck"
          ];
        };

        tyckPort = mkOption {
          type = port;
          default = 3979;
        };

        host = mkOption {
          type = str;
        };

        # everything can be set from environmentFile, so just use that, don't
        # allow any extra arguments or something
        environmentFile = mkOption {
          type = nullOr str;
          default = null;
        };

        passwordFile = mkOption {
          type = nullOr str;
          description = "Admin credentials, generate with `tyck-htpasswd --htpasswd outfile username`";
          default = null;
          example = "/var/run/secrets/tyck-htpasswd";
        };
      };
      config = mkIf cfg.enable {
        assertions = [
          {
            assertion = (cfg.environmentFile != null) || (cfg.passwordFile != null);
            message = "One of `services.tyck.environmentFile` or `services.tyck.passwordFile` must be set. Otherwise the service will fail guaranteed because there's no password provided.";
          }
          {
            assertion =
              config.services.nginx.enable
              && (
                with config.services.nginx.virtualHosts.${cfg.host}.locations."/"; root != null || proxyPass != null
              );
            message = ''Nginx must be enabled with the virtualHost for `${cfg.host}` configured. I.e. `services.nginx.virtualHosts."${cfg.host}".locations."/"` must be set.'';
          }
        ];

        services.postgresql = {
          ensureUsers = [
            {
              name = "tyck";
              ensureDBOwnership = true;
            }
          ];
          ensureDatabases = [ "tyck" ];
        };

        users.users.tyck = {
          isSystemUser = true;
          group = "tyck";
        };
        users.groups.tyck = { };

        systemd.services.tyck = {
          wantedBy = [ "multi-user.target" ];
          after = [ "network-online.target" ];
          wants = [ "network-online.target" ];
          requires = [ "postgresql.service" ];

          environment = {
            HOST = "127.0.0.1";
            PORT = toString cfg.tyckPort;
            BASE_URL = "https://${cfg.host}/tyck"; # to match nginx proxy config
            DATABASE_URL = "postgres:///tyck?host=/var/run/postgresql";
            MODERATORS_HTPASSWD = mkIf (cfg.passwordFile != null) cfg.passwordFile;
            MIGRATE_DB = "true";
          };

          serviceConfig = {
            ExecStart = getExe' cfg.package "tyck";
            EnvironmentFile = mkIf (cfg.environmentFile != null) cfg.environmentFile;
            User = "tyck";
            Group = "tyck";

            ProtectHome = "tmpfs";
            WorkingDirectory = "~";
            MemoryDenyWriteExecute = true;
            PrivateDevices = true;
            PrivateTmp = true;
            ProtectSystem = "strict";
            ProtectControlGroups = true;
            RestrictSUIDSGID = true;
            RestrictRealtime = true;
            LockPersonality = true;
            ProtectKernelLogs = true;
            ProtectKernelTunables = true;
            ProtectHostname = true;
            ProtectKernelModules = true;
            PrivateUsers = true;
            ProtectClock = true;
            SystemCallArchitectures = "native";
            SystemCallErrorNumber = "EPERM";
            SystemCallFilter = "@system-service";

            RestartSec = "1s";
            RestartSteps = 4;
            RestartMaxDelaySec = "50s";
          };
        };

        services.nginx.virtualHosts."${cfg.host}" = {
          extraConfig = ''
            ssi on;
          '';
          locations."/tyck/".extraConfig = ''
            proxy_pass http://127.0.0.1:${toString cfg.tyckPort}/;
            proxy_set_header X-Forwarded-For $remote_addr;
            proxy_set_header X-Original-Uri $request_uri;
          '';
        };
      };
    };
}
