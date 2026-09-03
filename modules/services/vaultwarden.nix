{
  flake.modules.nixos.services-vaultwarden =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    let
      cfg = config.infra.vaultwarden;
      inherit (lib)
        types
        mkEnableOption
        mkPackageOption
        mkOption
        mkIf
        ;
      inherit (types) str nullOr;
    in
    {
      options.infra.vaultwarden = {
        enable = mkEnableOption "vaultwarden";
        package = mkPackageOption pkgs "vaultwarden" { };

        domain = mkOption {
          type = str;
          default = "pass.${(import ../_consts.nix).domain}";
        };

        environmentFile = mkOption {
          type = nullOr str;
          default = config.sops.secrets.vaultwarden.path;
        };
      };

      config = {
        sops.secrets.vaultwarden = {
          sopsFile = ../../secrets/vaultwarden.secret;
          format = "binary";
          owner = "vaultwarden";
          group = "vaultwarden";
          mode = "0440";
        };

        services.vaultwarden = {
          inherit (cfg)
            enable
            package
            environmentFile
            domain
            ;
          configureNginx = true;
          config = {
            SIGNUPS_ALLOWED = false;
          };
        };

        services.nginx.virtualHosts."${cfg.domain}" = mkIf cfg.enable {
          enableACME = true;
          forceSSL = true;
        };
      };
    };

  flake.modules.homeManager.firefox = { pkgs, ... }: {
    programs.firefox.profiles.dev-edition-default.extensions.packages = [
      pkgs.nur.repos.rycee.firefox-addons.bitwarden
    ];
  };
}
