{ lib, config, ... }:
# How to add a user:
# Make create modules/users/<username>.nix and define the following outputs:
# - users.<username>
# - flake.modules.homeManager.<username>
# - (optional) flake.modules.homeManager."<username>@<hostname>" for every host
#   you'd want to use the user on with host-specific settings.
# Then, when used with NixOS, you should
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
      default = null;
      type = with lib.types; nullOr str;
    };

    locale = lib.mkOption {
      description = "Default display language";
      default = null;
      type = with lib.types; nullOr str;
    };

    timeZone = lib.mkOption {
      description = "NixOS timezone";
      default = null;
      type = with lib.types; nullOr str;
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
          inherit (hm.config.home) username;
          user = config.users.${username} or null;
        in
        {
          programs.git.settings = lib.mkIf (user != null) {
            signing.key = user.gpgPubKey or null;
            user = {
              name = user.fullName;
              inherit (user) email;
            };
          };
        };

      homeManager.jujutsu =
        hm:
        let
          inherit (hm.config.home) username;
          user = config.users.${username} or null;
        in
        {
          programs.jujutsu.settings.user = lib.mkIf (user != null) {
            inherit (user) email;
            name = user.fullName;
          };
        };

      nixos = lib.mapAttrs' (
        n: v:
        lib.nameValuePair "users-${n}" {
          time.timeZone = lib.mkIf (v.timeZone != null) (lib.mkDefault v.timeZone);
          i18n.defaultLocale = lib.mkIf (v.locale != null) (lib.mkDefault v.locale);
        }
      ) config.users;
    };
  };
}
