{
  flake.modules.homeManager.profiles-noctalia =
    { self', pkgs, ... }:
    {
      xdg.stateFile."noctalia/settings.toml" = {
        force = true;
        source = pkgs.writers.writeTOML "noctalia-settings.toml" {
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
          theme.builtin = "Catppuccin"; # TODO: move to themes-catppuccin??
          wallpaper = {
            default.path = self'.packages.my-wallpaper.passthru.kdeFilePath;
            # directory = "";
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
        };
      };
    };
}
