# WARNING: plasma theming might break, so don't use with profiles-plasma, I guess
{ lib, ... }:
{
  flake.modules.nixos.profiles-dank =
    { pkgs, ... }:
    {
      programs.niri.enable = true;

      services.displayManager = {
        dms-greeter = {
          enable = true;
          compositor.name = "niri";
        };
        sddm.enable = lib.mkForce false;
        sddm.wayland.enable = lib.mkForce false;
        gdm.enable = lib.mkForce false;
      };

      programs.dms-shell = {
        enable = true;
        systemd.enable = false;
      };

      environment.systemPackages = with pkgs; [ xwayland-satellite ];

      xdg.portal = {
        enable = true;
        extraPortals = with pkgs; [
          kdePackages.xdg-desktop-portal-kde
          xdg-desktop-portal-gtk
        ];
        config.common.default = "kde";
        config.niri."org.freedesktop.impl.portal.FileChooser" = [ "kde" ];
      };

    };

  flake.modules.homeManager.profiles-dank =
    { pkgs, lib, ... }:
    {
      # let HM manage DMS (see ./extra-options.nix)
      programs.dms-shell = {
        enable = true;
        package = null;
      };
      # let DMS manage GTK themes
      gtk.enable = lib.mkForce false;
      modules.terminals.foot.enable = lib.mkDefault true;
      home.packages = with pkgs; [
        wl-clipboard
        brightnessctl
        pipewire
        rofi
      ];

      services.hypridle = {
        enable = true;
        settings =
          let
            # DMS disables the monitors when the lock is called
            lock_cmd = "dms ipc call lock lock";
          in
          {
            general = {
              inherit lock_cmd;
              ignore_dbus_inhibit = false;
            };

            listener = [
              {
                timeout = 440;
                on-timeout = "brightnessctl -s set 5%";
                on-resume = "brightnessct -r";
              }
              {
                timeout = 500;
                on-timeout = lock_cmd;
              }
            ];
          };
      };
    };

  flake.modules.nixos.feather.services.displayManager.dms-greeter.enable = lib.mkForce false;
}
