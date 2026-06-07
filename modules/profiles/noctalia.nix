{
  self,
  lib,
  inputs,
  ...
}:
{
  flake-inputs.noctalia = {
    url = "github:noctalia-dev/noctalia-shell/v5";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake.modules.nixos.profiles-noctalia =
    { inputs', ... }:
    {
      imports = [ self.modules.nixos.programs-niri-common ];

      services.displayManager = {
        sddm.enable = lib.mkForce false;
        sddm.wayland.enable = lib.mkForce false;
        gdm.enable = lib.mkForce false;
        plasma-login-manager.enable = lib.mkForce false;
      };

      programs.regreet = {
        enable = true;
        settings.GTK.application_prefer_dark_theme = true;
      };

      environment.systemPackages = lib.singleton inputs'.noctalia.packages.default;

      # recommended by docs
      networking.networkmanager.enable = lib.mkDefault true;
      hardware.bluetooth.enable = lib.mkDefault true;
      services.power-profiles-daemon.enable = lib.mkDefault true;
      services.upower.enable = lib.mkDefault true;
    };

  flake.modules.homeManager.profiles-noctalia =
    { pkgs, ... }:
    {
      imports = [
        self.modules.homeManager.programs-niri-common
        inputs.noctalia.homeModules.default
      ];

      # There's no font configuration here, since by default the new noctalia
      # listens properly to fontconfig sans-serif and monospace defaults. Hence
      # I don't have to set anything here anymore or anything noctalia-specific
      # in fonts.nix
      programs.noctalia = {
        enable = true;
        package = null;
        settings = {
          bar.default = {
            start = [
              "control-center"
              "workspaces"
              "clock"
            ];
            center = [ "media" ];
            end = [
              "tray"
              "notifications"
              "network"
              "bluetooth"
              "volume"
              "brightness"
              "battery"
              "session"
            ];
            margin_edge = 0;
            margin_ends = 0;
            radius = 0;
            shadow = false;
          };
          desktop_widgets.enabled = false;
          shell = {
            animation.speed = 1.6;
            clipboard_enabled = false;
            panel = {
              borders = false;
              shadow = false;
            };
            settings_show_advanced = true;
            telemetry_enabled = false;
          };
          widget = {
            battery = {
              display_mode = "graphic";
              show_label = false;
            };
            clock.format = "{:%H:%M}\\n{:%Y-%m-%d}";
            control-center.custom_image = "${pkgs.nixos-icons}/share/icons/hicolor/128x128/apps/nix-snowflake-white.png";
            session.color = "error";
          };
          idle.behavior = {
            lock = {
              action = "lock";
              enabled = true;
              timeout = 600;
            };
            lock-and-suspend = {
              action = "lock_and_suspend";
              enabled = true;
              timeout = 900;
            };
            screen-off = {
              action = "screen_off";
              enabled = true;
              timeout = 660;
            };
          };
        };
      };

    };

  flake.modules.homeManager."tomvd@boomer".programs.noctalia.settings.idle.behavior.lock-and-suspend.enabled =
    lib.mkForce false;
}
