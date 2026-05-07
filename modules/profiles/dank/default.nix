# WARNING: plasma theming might break, so don't use with profiles-plasma, I guess
{ self, lib, ... }:
{
  flake.modules.nixos.profiles-dank = {
    imports = [ self.modules.nixos.programs-niri-common ];

    programs.niri.enable = true;

    services.displayManager = {
      sddm.enable = lib.mkForce false;
      sddm.wayland.enable = lib.mkForce false;
      gdm.enable = lib.mkForce false;
      plasma-login-manager.enable = lib.mkForce false;

      dms-greeter = {
        enable = true;
        compositor.name = "niri";
      };
    };

    programs.dms-shell = {
      enable = true;
      systemd.enable = false;
    };
  };

  flake.modules.homeManager.profiles-dank = {
    imports = [ self.modules.homeManager.programs-niri-common ];
    # let HM manage DMS (see ./extra-options.nix)
    programs.dms-shell = {
      enable = true;
      package = null;
    };

    # let DMS manage GTK themes
    gtk.enable = lib.mkForce false;

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
