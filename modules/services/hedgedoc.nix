let
  inherit (import ../_consts.nix) domain;
in
{
  flake.modules.nixos.services-hedgedoc =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    let
      cfg = config.infra.md;

      inherit (lib)
        mkEnableOption
        mkPackageOption
        mkIf
        mkMerge
        mkOption
        ;

      inherit (lib.types)
        attrsOf
        str
        raw
        ;
    in
    {
      options.infra.md = {
        enable = mkEnableOption "hedgedoc";
        package = mkPackageOption pkgs "hedgedoc" { };

        domain = mkOption {
          type = str;
          default = "md.${domain}";
        };

        extraSettings = mkOption {
          type = attrsOf raw;
          default = { };
        };

        environmentFile = mkOption {
          type = str;
          default = config.sops.secrets.hedgedoc-default-credentials.path;
        };
      };

      config = mkMerge [
        {
          sops.secrets.hedgedoc-default-credentials = {
            mode = "0400";
            # this default configures oauth2 with git.toostveen.nl
            sopsFile = ../../secrets/hedgedoc-default-credentials.secret;
            format = "binary";
            owner = config.systemd.services.hedgedoc.serviceConfig.User;
            group = config.systemd.services.hedgedoc.serviceConfig.Group;
          };
        }
        (mkIf cfg.enable {
          services.hedgedoc = {
            enable = true;
            inherit (cfg) package environmentFile;
            configureNginx = true;
            settings = {
              inherit (cfg) domain;
              protocolUseSSL = true;
              enableUploads = "registered";
              email = false;
              allowEmailRegister = false;
              allowAnonymous = false;
            }
            // cfg.extraSettings;
          };

          services.nginx.virtualHosts.${cfg.domain}.enableACME = true;
        })
      ];
    };
}
