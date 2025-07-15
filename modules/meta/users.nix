{ lib, config, ... }:
let
  userEntry.options = {
    fullName = lib.mkOption {
      description = "Full user name (email)";
      type = lib.types.str;
    };

    email = lib.mkOption {
      description = "Email for git/gpg/etc.";
      type = lib.types.str;
    };

    gpgPubKey = lib.mkOption {
      description = "GPG public key fingerprint";
      type = lib.types.str;
    };

    locale = lib.mkOption {
      description = "Default display language";
      type = lib.types.str;
    };

    timeZone = lib.mkOption {
      description = "NixOS timezone";
      type = lib.types.str;
    };
  };
in
{
  options.users = lib.mkOption {
    description = "Defines users for home-manager/nixos";
    type = with lib.types; attrsOf (submodule userEntry);
    default = { };
  };

  config = {
    flake.modules = {
      homeManager.git =
        hm:
        let
          user = config.users.${hm.config.home.username};
        in
        {
          programs.git = {
            extraConfig.signing.key = user.gpgPubKey;
            userEmail = user.email;
            userName = user.fullName;
          };
        };

      homeManager.jujutsu =
        hm:
        let
          user = config.users.${hm.config.home.username};
        in
        {
          programs.jujutsu.settings.user = {
            inherit (user) email;
            name = user.fullName;
          };
        };

      nixos = lib.mapAttrs' (
        n: v:
        lib.nameValuePair "users-${n}" {
          time.timeZone = lib.mkDefault v.timeZone;
          i18n.defaultLocale = lib.mkDefault v.locale;
        }
      ) config.users;
    };
  };
}
