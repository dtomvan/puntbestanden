{ lib, config, ... }:
# How to add a user:
# Make create modules/users/<username>.nix and define the following outputs:
# - users.<username>
# - flake.modules.homeManager.<username>
# - (optional) flake.modules.homeManager."<username>@<hostname>" for every host
#   you'd want to use the user on with host-specific settings.
# Then, when used with NixOS, you should
let
  inherit (lib)
    literalExpression
    mapAttrs'
    mkDefault
    mkEnableOption
    mkIf
    mkOption
    nameValuePair
    ;
  inherit (lib.types)
    attrsOf
    functionTo
    nullOr
    package
    str
    submodule
    ;

  userEntry.options = {
    fullName = mkOption {
      description = "Full user name (email)";
      type = str;
    };

    email = mkOption {
      description = "Email for git/gpg/etc.";
      type = str;
    };

    gpgPubKey = mkOption {
      description = "GPG public key fingerprint";
      default = null;
      type = nullOr str;
    };

    locale = mkOption {
      description = "Default display language";
      default = null;
      type = nullOr str;
    };

    timeZone = mkOption {
      description = "NixOS timezone";
      default = null;
      type = nullOr str;
    };

    nixvim = {
      enable = mkEnableOption "installing nixvim";
      package = mkOption {
        description = "package selector for nixvim to install";
        type = functionTo package |> nullOr;
        default = null;
        example = literalExpression ''
          { self', host, ... }: if host.hostName == "feather" then self'.packages.nixvim-minimal else self'.packages.nixvim
        '';
      };
    };
  };
in
{
  options.users = mkOption {
    description = "Defines users for home-manager/nixos";
    type = attrsOf (submodule userEntry);
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
          programs.git = mkIf (user != null) {
            signing = {
              format = if user.gpgPubKey != null then "openpgp" else null;
              key = user.gpgPubKey or null;
            };

            settings.user = {
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
          programs.jujutsu.settings.user = mkIf (user != null) {
            inherit (user) email;
            name = user.fullName;
          };
        };

      nixos = mapAttrs' (
        n: v:
        nameValuePair "users-${n}" {
          users.users.${n}.isNormalUser = true;
          time.timeZone = mkIf (v.timeZone != null) (mkDefault v.timeZone);
          i18n.defaultLocale = mkIf (v.locale != null) (mkDefault v.locale);
        }
      ) config.users;
    };
  };
}
