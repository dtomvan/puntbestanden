{
  flake.modules.nixos.services-monitoring =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    let
      inherit (lib) mkOption mkIf singleton;
      inherit (lib.types)
        submodule
        str
        attrsOf
        listOf
        ;

      cfg = config.infra.monitoring.prometheus;
    in
    {
      options.infra.monitoring.prometheus.alerts = mkOption {
        type = submodule {
          imports = [
            ./_node-exporter.nix
            ./_nsoe.nix
          ];

          options.groups = mkOption {
            default = [ ];

            type =
              submodule {
                options = {
                  name = mkOption {
                    type = str;
                  };

                  rules = mkOption {
                    type =
                      submodule {
                        options = {
                          alert = mkOption {
                            type = str;
                          };
                          expr = mkOption {
                            type = str;
                          };
                          for = mkOption {
                            type = str;
                          };
                          labels = mkOption {
                            type = attrsOf str;
                            default = { };
                          };
                          annotations = mkOption {
                            type = attrsOf str;
                            default = { };
                          };
                        };
                      }
                      |> listOf;

                    default = [ ];
                  };
                };
              }
              |> listOf;
          };
        };
      };

      config.services.prometheus = mkIf cfg.enable {
        ruleFiles = singleton (pkgs.writers.writeJSON "prometheus-rules.json" cfg.alerts);
      };
    };
}
