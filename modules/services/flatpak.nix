{
  flake.modules.nixos.profiles-graphical =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    {
      options.services.flatpak.packages = lib.mkOption {
        description = "list of pre-installed flatpak apps";
        type = with lib.types; listOf str;
        default = [
          "com.github.tchx84.Flatseal"
          "com.obsproject.Studio"
          "org.gnome.World.PikaBackup"
          "io.github.kolunmi.Bazaar"
        ];
        example = [
          "org.kde.okular"
          "com.discordapp.Discord"
        ];
      };

      config.services.flatpak = {
        enable = true;
        # so the user can run `flatpak-managed-install` when they want to
        # update/install apps that are out of date or gone
        package = pkgs.activatable-flatpak.override {
          inherit (config.services.flatpak) packages;
        };
      };

      config.security.polkit.enable = true;
    };

  perSystem =
    {
      pkgs,
      lib,
      self',
      ...
    }:
    {
      legacyPackages.activatable-flatpak = lib.makeOverridable (
        {
          packages ? [ ],
        }:
        pkgs.buildEnv {
          name = "activatable-flatpak";
          paths = [
            pkgs.flatpak
            (pkgs.writeShellScriptBin "flatpak-managed-install" ''
              # when run under deploy-rs: $PROFILE set
              # if not: flatpak is already installed and thus it has to be under /run/current-system
              flatpak="''${PROFILE:-/run/current-system/sw}/bin/flatpak"
              "$flatpak" remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
              ${lib.optionalString (packages != [ ]) ''
                "$flatpak" install --noninteractive --or-update ${lib.strings.escapeShellArgs packages}
              ''}
              "$flatpak" update --noninteractive
            '')
          ];
        }
      );

      packages.activatable-flatpak = self'.legacyPackages.activatable-flatpak { };
    };
}
