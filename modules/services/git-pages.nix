{ lib, ... }:
let
  inherit (lib)
    getExe
    getExe'
    mkOption
    mkIf
    mkOptionDefault
    optional
    singleton
    mkEnableOption
    mkPackageOption
    ;

  inherit (lib.types)
    package
    port
    nullOr
    str
    toml
    ;

  settings = mkOption {
    type = toml;
    description = "Settings to set in git-pages.toml. See https://codeberg.org/git-pages/git-pages";
    default = toml.emptyValue;
  };
in

{
  pkgs-overlays = singleton (
    final: prev: {
      git-pages = prev.git-pages.overrideAttrs {
        passthru = prev.git-pages.passthru // {
          services.default =
            { config, ... }:
            let
              cfg = config.git-pages;
              configFile = "git-pages.toml";
              configOutPath = config.configData.${configFile}.path;

              format = prev.formats.toml { };
            in
            {
              _class = "service";

              options.git-pages = {
                package = mkOption {
                  description = "Package to use for git-pages";
                  default = final.git-pages;
                  defaultText = "The git-pages package that provided this module.";
                  type = package;
                };

                inherit settings;
              };

              config = {
                process.argv = [
                  (getExe cfg.package)
                  "-config"
                  configOutPath
                ];

                configData."${configFile}".source = format.generate "git-pages.toml" cfg.settings;

                systemd.service = {
                  description = "git-pages forge-agnostic static site server";
                  documentation = [ "https://codeberg.org/git-pages/git-pages" ];

                  after = [ "network.target" ];
                  wants = [ "network.target" ];
                  wantedBy = [ "multi-user.target" ];
                  serviceConfig = {
                    ExecStartPre = "${getExe' final.coreutils "mkdir"} -p data";
                    Restart = "always";

                    StateDirectory = "git-pages";
                    WorkingDirectory = "/var/lib/git-pages";
                    BindReadOnlyPaths = [ configOutPath ];

                    # hardening BS
                    DynamicUser = true;
                    ProtectHome = true;
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
                  };
                };
              };
            };
        };
      };
    }
  );

  flake.modules.nixos.services-git-pages =
    { config, pkgs, ... }:
    let
      cfg = config.infra.git-pages;
    in
    {
      options.infra.git-pages = {
        enable = mkEnableOption "git-pages";
        package = mkPackageOption pkgs "git-pages" { };

        inherit settings;

        port = mkOption {
          description = "Port to open the main pages server on";
          default = 3000;
          type = port;
        };

        caddyPort = mkOption {
          description = "Port for caddy";
          default = 3001;
          type = nullOr port;
        };

        metricsPort = mkOption {
          description = "Port to open a prometheus exporter on";
          default = 3002;
          type = nullOr port;
        };

        secretFile = mkOption {
          description = "Path to secrets.toml";
          default = null;
          type = nullOr str;
        };
      };

      config = {
        infra.git-pages.settings = {
          server = {
            pages = mkOptionDefault "tcp/localhost:${toString cfg.port}";
            caddy = mkOptionDefault "tcp/localhost:${
              if cfg.caddyPort == null then "-" else toString cfg.caddyPort
            }";
            metrics = mkOptionDefault "tcp/localhost:${
              if cfg.metricsPort == null then "-" else toString cfg.metricsPort
            }";
          };
        };

        infra.monitoring.extraScrapeConfigs.git-pages.port = cfg.metricsPort;

        system.services.git-pages = mkIf cfg.enable {
          _class = "service";
          imports = [ cfg.package.services.default ];
          git-pages = { inherit (cfg) settings; };

          # automatically gets picked up by git-pages!
          systemd.service.serviceConfig.LoadCredential = optional (
            cfg.secretFile != null
          ) "secrets.toml:${cfg.secretFile}";
        };
      };
    };

  perSystem = { pkgs, ... }: {
    checks.git-pages = pkgs.git-pages.tests.modularService;

    packages.git-pages-push = pkgs.writeShellApplication {
      name = "git-pages-push";
      runtimeInputs = builtins.attrValues {
        inherit (pkgs)
          sops
          coreutils
          git-pages-cli
          ;
      };
      derivationArgs = {
        preferLocalBuild = true;
        allowSubstitutes = false;
      };
      inheritPath = false;
      text = ''
        set -x
        outPath="''${1:?}"
        token="$(sops decrypt ${../../secrets/git-pages-push-token.secret} | tr -d '\n')"
        git-pages-cli \
          "''${2:-"https://${(import ../_consts.nix).domain}"}" \
          --upload-dir "$outPath" \
          --server "''${3:-"${(import ../_consts.nix).domain}"}" \
          --token "$token"
      '';
    };
  };
}
