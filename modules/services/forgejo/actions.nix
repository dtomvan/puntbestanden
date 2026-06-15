{
  flake.modules.nixos.services-forgejo =
    { lib, config, ... }:
    let
      cfg = config.infra.fj;
      acfg = cfg.actions;

      inherit (lib)
        mkEnableOption
        mkDefault
        mkOption
        mkIf
        trim
        ;

      inherit (lib.types) listOf nullOr str;
    in
    {
      # TASK(20260515-180913): make it possible to run multiple instances
      options.infra.fj.actions = {
        enable = mkEnableOption "Github actions on forgejo (same machine)";
        enableNative = mkEnableOption "Native actions thru the `native` label";
        domain = mkOption {
          description = "Domain which hosts the actual fj forge";
          type = nullOr str;
          default = cfg.domain or null;
        };
        extraLabels = mkOption {
          description = "Labels to additionally include on top of act and nix";
          default = [ ];
          type = listOf str;
        };
        runnerName = mkOption {
          description = "Name for runner to grab credentials thru sops automatically.";
          type = str;
          default = config.networking.hostName;
          example = "elated-minsky";
        };
      };

      # Add support for actions, based on act: https://github.com/nektos/act
      config = mkIf acfg.enable {
        virtualisation.podman.enable = mkDefault true;

        services.forgejo.settings.actions = {
          ENABLED = true;
          DEFAULT_ACTIONS_URL = "https://data.forgejo.org";
        };

        services.forgejo-runner.instances.default = {
          enable = true;

          secrets.server.connections.default.token_url = config.sops.secrets.forgejo-runner-token.path;

          settings = {
            server.connections.default = {
              url = "https://${acfg.domain}";
              uuid = builtins.readFile ../../../secrets/forgejo-runner-uuid.${acfg.runnerName} |> trim;
            };

            runner.labels = [
              "nix:docker://git.toostveen.nl/tom/lix-with-node:latest"
            ]
            ++ lib.optionals acfg.enableNative [
              "native:host"
            ]
            ++ acfg.extraLabels;
          };
        };

        sops.secrets.forgejo-runner-token = {
          # not generatable anymore, need to set that based on the output of the admin panel
          sopsFile = ../../../secrets/forgejo-runner-token.${acfg.runnerName}.secret;
          owner = "forgejo";
          format = "binary";
        };
      };
    };
}
