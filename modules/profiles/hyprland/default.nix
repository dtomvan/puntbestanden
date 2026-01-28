{ self, config, ... }:
{
  flake.modules = {
    nixos.hyprland =
      {
        pkgs,
        lib,
        config,
        ...
      }:
      {
        # hyprland doesn't set breeze by default, but we do use kde packages. To make
        # them not look like they are the QT apps from your grandma, we specifically
        # specify qt settings here

        qt = {
          enable = true;
          platformTheme = "qt5ct"; # also does qt6ct
          style = "breeze";
        };

        xdg.portal = {
          enable = true;
          extraPortals = with pkgs; [
            kdePackages.xdg-desktop-portal-kde
            xdg-desktop-portal-gtk
          ];
          config.common.default = "kde";
        };

        programs.hyprland = {
          enable = true;
          withUWSM = true;
        };

        # why do I need to set this???!?!?
        services.upower.enable = true;

        # KDE has its own support, and Hyprland of course doesn't
        services.blueman.enable = lib.mkDefault config.hardware.bluetooth.enable;

        programs.hyprlock.enable = true;
        services.hypridle.enable = true;

        services.playerctld.enable = true;

        environment.sessionVariables.NIXOS_OZONE_WL = "1";
      };

    homeManager.hyprland =
      {
        self',
        lib,
        host,
        ...
      }:
      let
        myPkgs = self'.packages;
      in
      {
        imports = [ self.modules.homeManager.services-fnott ];

        services.swayosd.enable = true;
        services.hyprpolkitagent.enable = true;

        wayland.windowManager.hyprland = {
          enable = true;
          systemd.enable = false;
          settings = {
            "$mod" = "SUPER";

            monitor = lib.optional (host == config.hosts.tpx1g8) ",preferred,auto,1.25";

            general = {
              gaps_in = 4;
              gaps_out = 10;
              border_size = 2;
            };

            input = {
              kb_layout = "us,gr";
              kb_options = "compose:ralt";
              touchpad.natural_scroll = true;
            };

            misc = {
              force_default_wallpaper = 1;
              disable_hyprland_logo = true;
            };

            exec-once = [
              "clipse -listen"
              "upower-notify"
              "qs -p ${myPkgs.quickshellConfig}"
            ];
          };
        };
      };
  };
}
