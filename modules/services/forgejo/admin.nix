toplevel: {
  flake.modules.nixos.services-forgejo =
    { config, lib, ... }:
    let
      cfg = config.infra.fj.admin;
      inherit (lib)
        mkIf
        mkEnableOption
        mkDefault
        mkOption
        ;
      inherit (lib.types) str;
    in
    {
      options.infra.fj.admin = {
        enable = mkEnableOption "creating an admin user";

        name = mkOption {
          description = "The admin users' name. Note, Forgejo doesn't allow creation of an account named \"admin\"";
          type = str;
          default = config.networking.hostName;
          example = "tomvd";
        };

        passwordFile = mkOption {
          description = "The admin user's password. Works like `users.users.initialPasswordFile`";
          type = str;
          default = config.sops.secrets.forgejo-admin-password.path;
          defaultText = "There's a default password set as a sops secret as a fallback.";
          example = "/run/secrets/forgejo-password";
        };

        email = mkOption {
          description = "The admin user's email. Only works when mailer is enabled";
          type = str;
          default =
            if config.services.forgejo.settings.mailer.ENABLED or false then
              # default to tomvd's email, whatever it is currently
              toplevel.config.users.tomvd.email
            else
              # we don't need an actual email if the mailer isn't enabled
              "root@localhost";
        };

        mustChangePassword = mkEnableOption "set --must-change-password";
      };

      config = mkIf cfg.enable {
        services.forgejo.settings.service.DISABLE_REGISTRATION = mkDefault cfg.enable;

        sops.secrets.forgejo-admin-password = {
          owner = "forgejo";
          sopsFile = ../../../secrets/forgejo-admin-password.secret;
          format = "binary";
        };

        systemd.services.forgejo.preStart = ''
          ${lib.getExe config.services.forgejo.package} admin user create ${
            lib.cli.toCommandLineShellGNU { } {
              inherit (cfg) email;
              must-change-password = cfg.mustChangePassword;
              username = cfg.name;
              admin = true;
            }
          } --password "$(tr -d '\n' < ${cfg.passwordFile})" || true
        '';
      };
    };
}
