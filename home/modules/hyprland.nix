{
  pkgs,
  lib,
  host,
  ...
}:
{
  # TODO: less hardcoding, more flexibility
  home.packages = with pkgs; [
    alacritty
    kdePackages.dolphin
    grimblast
    wireplumber
    brightnessctl
    playerctl
    power-profiles-daemon
    clipse
    fnott
    upower
    upower-notify
    eww
  ];

  services.swayosd.enable = true;

  wayland.windowManager.hyprland = {
    enable = true;
    package = null;
    portalPackage = null;
    systemd.enable = false;
    settings = {
      "$mod" = "SUPER";

      monitor = lib.optional (host == (import ../../hosts.nix).tpx1g8) ",preferred,auto,1.25" ++ [
        # struts
        # ", addreserved, 30, 0, 0, 0"
      ];

      env = lib.optionals (host.hardware.cpuVendor == "nvidia") [
        "LIBVA_DRIVER_NAME,nvidia"
        "__GLX_VENDOR_LIBRARY_NAME,nvidia"
      ];

      general = {
        gaps_in = 4;
        gaps_out = 10;

        border_size = 2;

        "col.active_border" = "rgba(33ccffee) rgba(00ff99ee) 45deg";
        "col.inactive_border" = "rgba(595959aa)";
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

      decoration = {
        rounding = 10;
        rounding_power = 2;

        active_opacity = 1.0;
        inactive_opacity = 0.9;

        blur = {
          enabled = true;
          size = 3;
          passes = 1;

          vibrancy = 0.1696;
        };
      };

      animations = {
        enabled = true;
        bezier = [
          "easeOutQuint,0.23,1,0.32,1"
          "easeInOutCubic,0.65,0.05,0.36,1"
          "linear,0,0,1,1"
          "almostLinear,0.5,0.5,0.75,1.0"
          "quick,0.15,0,0.1,1"
        ];
        animation = [
          "global, 1, 10, default"
          "border, 1, 5.39, easeOutQuint"
          "windows, 1, 4.79, easeOutQuint"
          "windowsIn, 1, 4.1, easeOutQuint, popin 87%"
          "windowsOut, 1, 1.49, linear, popin 87%"
          "fadeIn, 1, 1.73, almostLinear"
          "fadeOut, 1, 1.46, almostLinear"
          "fade, 1, 3.03, quick"
          "layers, 1, 3.81, easeOutQuint"
          "layersIn, 1, 4, easeOutQuint, fade"
          "layersOut, 1, 1.5, linear, fade"
          "fadeLayersIn, 1, 1.79, almostLinear"
          "fadeLayersOut, 1, 1.39, almostLinear"
          "workspaces, 1, 2, almostLinear, slide"
          "workspacesIn, 1, 2, almostLinear, slide"
          "workspacesOut, 1, 2, almostLinear, slide"
        ];
      };

      gestures.workspace_swipe = true;

      # smart gaps
      workspace = [
        "w[tv1], gapsout:0, gapsin:0"
        "f[1], gapsout:0, gapsin:0"
      ];

      exec-once = [
        "clipse -listen"
        "fnott"
        "upower-notify"
      ];

      bind =
        [
          "$mod, h, movefocus, l"
          "$mod, l, movefocus, r"
          "$mod, k, movefocus, u"
          "$mod, j, movefocus, d"
          "$mod, F, exec, firefox-developer-edition"
          "$mod, return, exec, alacritty"
          "$mod, space, exec, tofi-drun --drun-launch=true"
          "$mod, E, exec, dolphin"
          "$mod, Q, killactive,"
          "$mod, V, togglefloating,"
          '', Print, exec, grimblast copysave area ~/Pictures/Screenshots/Screenshot_"$(date +'%Y%m%d_%H%M%S')".png''
          "$mod, V, exec, $terminal --class clipse -e 'clipse'"
          "$mod ALT, L, exec, hyprlock"
          "$mod, B, exec, eww open bar --toggle"
        ]
        ++ (builtins.concatLists (
          builtins.genList (
            i:
            let
              ws = i + 1;
            in
            [
              "$mod, code:1${toString i}, workspace, ${toString ws}"
              "$mod SHIFT, code:1${toString i}, movetoworkspace, ${toString ws}"
            ]
          ) 9
        ));

      bindm = [
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
      ];

      bindel = [
        # ",XF86AudioRaiseVolume, exec, wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"
        # ",XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
        # ",XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        # ",XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
        # ",XF86MonBrightnessUp, exec, brightnessctl -e4 -n2 set 5%+"
        # ",XF86MonBrightnessDown, exec, brightnessctl -e4 -n2 set 5%-"

        ",XF86AudioRaiseVolume, exec, swayosd-client --output-volume raise"
        ",XF86AudioLowerVolume, exec, swayosd-client --output-volume lower"
        ",XF86AudioMute, exec, swayosd-client --output-volume mute-toggle"
        ",XF86AudioMicMute, exec, swayosd-client --input-volume mute-toggle"
        ",XF86MonBrightnessUp, exec, swayosd-client --brightness raise"
        ",XF86MonBrightnessDown, exec, swayosd-client --brightness lower"

      ];
      bindl = [
        ", XF86AudioNext, exec, playerctl next"
        ", XF86AudioPause, exec, playerctl play-pause"
        ", XF86AudioPlay, exec, playerctl play-pause"
        ", XF86AudioPrev, exec, playerctl previous"
      ];

      windowrule = [
        # no border when only
        "bordersize 0, floating:0, onworkspace:w[tv1]"
        "rounding 0, floating:0, onworkspace:w[tv1]"
        "bordersize 0, floating:0, onworkspace:f[1]"
        "rounding 0, floating:0, onworkspace:f[1]"

        # real fullscreen
        "suppressevent maximize, class:.*"

        "nofocus,class:^$,title:^$,xwayland:1,floating:1,fullscreen:0,pinned:0"

        "opacity 0.0 override, class:^(xwaylandvideobridge)$"
        "noanim, class:^(xwaylandvideobridge)$"
        "noinitialfocus, class:^(xwaylandvideobridge)$"
        "maxsize 1 1, class:^(xwaylandvideobridge)$"
        "noblur, class:^(xwaylandvideobridge)$"
        "nofocus, class:^(xwaylandvideobridge)$"
      ];

      windowrulev2 = [
        "float,class:(clipse)"
        "size 622 652,class:(clipse)"
      ];
    };
  };

  services.hyprpaper =
    let
      wallpaper = pkgs.nixos-artwork.wallpapers.nineish-catppuccin-mocha.passthru.kdeFilePath;
    in
    {
      enable = true;
      settings = {
        ipc = "on";
        preload = [
          "${wallpaper}"
        ];
        wallpaper = [
          "DP-1,${wallpaper}"
        ];
      };
    };

  services.hyprpolkitagent.enable = true;

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
}
