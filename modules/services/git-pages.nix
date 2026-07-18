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
          tests.modularService = final.testers.runNixOSTest (
            { pkgs, ... }:
            let
              testSite = pkgs.runCommand "git-pages-testsite.tar" { } ''
                echo It works! > index.html
                tar cvf $out index.html
              '';
            in
            {
              name = "git-pages-modular-service";

              nodes.machine = {
                environment.systemPackages = [ pkgs.curl ];

                system.services.git-pages = {
                  _class = "service";
                  imports = [ pkgs.git-pages.services.default ];
                  git-pages = {
                    settings.server = {
                      pages = "tcp/:3000";
                      caddy = "tcp/:3001";
                      metrics = "tcp/:3002";
                    };
                  };
                  systemd.service.environment.PAGES_INSECURE = "1";
                };

                services.caddy = {
                  enable = true;
                  configFile =
                    builtins.toFile "Caddyfile"
                      # from upstream
                      # caddy
                      ''
                        {
                            admin off

                            persist_config off

                            auto_https disable_redirects

                            on_demand_tls {
                                permission http http://localhost:3001
                            }
                        }

                        https://, http:// {
                          tls {
                              on_demand
                          }

                          reverse_proxy http://localhost:3000
                        }
                      '';
                };

                networking.firewall.allowedTCPPorts = [ 80 ];
              };

              testScript = ''
                start_all()

                machine.wait_for_unit("caddy.service")
                machine.wait_for_open_port(80)
                machine.wait_for_unit("git-pages.service")
                machine.wait_for_open_port(3001)
                machine.wait_for_open_port(3002)
                machine.fail("curl -f http://localhost/.git-pages/health")
                machine.succeed("curl -f http://localhost/ -X PUT --data-binary @${testSite} --header 'Content-Type: application/x-tar'")
                machine.succeed("sleep 1")
                machine.succeed("curl -f http://localhost/.git-pages/health")
                machine.succeed("curl -f http://localhost/ | grep -F 'It works!'")
                machine.succeed("curl -f http://localhost:3002/metrics")
              '';
            }
          );

          services.default =
            { config, ... }:
            let
              cfg = config.git-pages;
              configFile = "git-pages.toml";
              configDrv = format.generate "git-pages.toml" cfg.settings;
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

                configData."${configFile}".source = configDrv;

                systemd.service = {
                  description = "git-pages forge-agnostic static site server";
                  documentation = [ "https://codeberg.org/git-pages/git-pages" ];

                  after = [ "network.target" ];
                  wants = [ "network.target" ];
                  wantedBy = [ "multi-user.target" ];
                  restartTriggers = [ configDrv ];
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
            pages = mkOptionDefault "tcp/0.0.0.0:${toString cfg.port}";
            caddy = mkOptionDefault (
              if cfg.caddyPort == null then "-" else "tcp/0.0.0.0:${toString cfg.caddyPort}"
            );
            metrics = mkOptionDefault (
              if cfg.metricsPort == null then "-" else "tcp/0.0.0.0:${toString cfg.metricsPort}"
            );
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
          --atomic \
          --upload-dir "$outPath" \
          --server "''${3:-"${(import ../_consts.nix).domain}"}" \
          --token "$token"
      '';
    };
  };
}
