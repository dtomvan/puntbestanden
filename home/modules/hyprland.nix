{ pkgs, ... }:
{
  home.packages = with pkgs; [
    alacritty
    kdePackages.dolphin
    grimblast
    wireplumber
    brightnessctl
    playerctl
  ];
  wayland.windowManager.hyprland = {
    enable = true;
    package = null;
    portalPackage = null;
    systemd.enable = false;
    settings = {
      "$mod" = "SUPER";

      env = [
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

      animations.enabled = true;

      bind =
        [
          "$mod, F, exec, firefox-developer-edition"
          "$mod, return, exec, alacritty"
          "$mod, R, exec, tofi-drun --drun-launch=true"
          "$mod, E, exec, dolphin"
          "$mod, Q, killactive,"
          "$mod, V, togglefloating,"
          '', Print, exec, grimblast copysave area ~/Pictures/Screenshots/Screenshot_"$(date +'%Y%m%d_%H%M%S')".png''
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
        ",XF86AudioRaiseVolume, exec, wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"
        ",XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
        ",XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        ",XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
        ",XF86MonBrightnessUp, exec, brightnessctl -e4 -n2 set 5%+"
        ",XF86MonBrightnessDown, exec, brightnessctl -e4 -n2 set 5%-"

      ];
      bindl = [
        ", XF86AudioNext, exec, playerctl next"
        ", XF86AudioPause, exec, playerctl play-pause"
        ", XF86AudioPlay, exec, playerctl play-pause"
        ", XF86AudioPrev, exec, playerctl previous"
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
}
