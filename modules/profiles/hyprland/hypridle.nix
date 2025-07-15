{
  flake.modules.homeManager.hyprland = {
    services.hypridle = {
      enable = true;
      package = null;
      settings =
        let
          lock_cmd = "hyprlock";
          after_sleep_cmd = "hyprctl dispatch dpms on";
        in
        {
          general = {
            inherit lock_cmd after_sleep_cmd;
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
            {
              timeout = 560;
              on-timeout = "hyprctl dispatch dpms off";
              on-resume = after_sleep_cmd;
            }
          ];
        };
    };
  };
}
