toplevel:
{
  flake.modules.nixos.services-monitoring =
    { lib, config, ... }:
    let
      inherit (lib) mkOption;
      inherit (lib.types) str;
    in
    {
      options.infra.monitoring = {
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
    };
}
