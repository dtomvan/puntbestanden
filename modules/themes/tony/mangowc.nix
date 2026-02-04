{
  perSystem =
    { self', pkgs, ... }:
    {
      packages.tonyMangowc = pkgs.fetchFromGitHub {
        owner = "tonybanters";
        repo = "mangowc-btw";
        rev = "a89934940fc4716218a940742005b581fe83a695";
        hash = "sha256-8+tor97KU4nlqTB3N5JRoowclxoxxqGsJ8abzQkGGA4=";
      };

      packages.tonyWallpaper = self'.legacyPackages.fetchWallpaper {
        url = "https://raw.githubusercontent.com/tonybanters/tonarchy/8769d9acc2757b1b89c6a535d8592e75283f2eef/assets/wallpapers/wall1.jpg";
        hash = "sha256-H4P244eEladsbPHxyG4qGBGHyjMyiaIHm62G7RMADJo=";
      };

      packages.waybar = pkgs.symlinkJoin {
        name = "waybar-tony-${pkgs.waybar.version}";
        paths = [ pkgs.waybar ];
        nativeBuildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          flags=(
            --config "${self'.packages.tonyMangowc}/config.jsonc"
            --style "${self'.packages.tonyMangowc}/style.css"
          )
          wrapProgram $out/bin/waybar \
            --add-flags "''${flags[*]}"
        '';
      };
    };

  flake.modules.homeManager.themes-tony =
    {
      self',
      pkgs,
      lib,
      config,
      options,
      ...
    }:
    let
      hasMango = options.wayland.windowManager ? mango;
      myPkgs = self'.packages;
      tonyMangowcConf = pkgs.runCommand "config.conf" { nativeBuildInputs = [ pkgs.gnused ]; } ''
        sed 's|/home/tony/|${config.home.homeDirectory}/|g' < ${myPkgs.tonyMangowc}/config.conf > $out
        cat << EOF >> $out
        bind=SUPER+SHIFT,1,tag,1,0
        bind=SUPER+SHIFT,2,tag,2,0
        bind=SUPER+SHIFT,3,tag,3,0
        bind=SUPER+SHIFT,4,tag,4,0
        bind=SUPER+SHIFT,5,tag,5,0
        bind=SUPER+SHIFT,6,tag,6,0
        bind=SUPER+SHIFT,7,tag,7,0
        bind=SUPER+SHIFT,8,tag,8,0
        bind=SUPER+SHIFT,9,tag,9,0

        bind=none,XF86AudioRaiseVolume,spawn,wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+
        bind=none,XF86AudioLowerVolume,spawn,wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
        bind=none,XF86AudioMute,spawn,wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
        bind=none,XF86AudioMicMute,spawn,wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle
        bind=none,XF86MonBrightnessUp,spawn,brightnessctl -e4 -n2 set 5%+
        bind=none,XF86MonBrightnessDown,spawn,brightnessctl -e4 -n2 set 5%-

        repeat_rate=25
        repeat_delay=600

        xkb_rules_options=compose:ralt

        disable_trackpad=0
        tap_to_click=1
        tap_and_drag=1
        drag_lock=1
        mouse_natural_scrolling=0
        trackpad_natural_scrolling=1
        disable_while_typing=1
        left_handed=0
        middle_button_emulation=1
        swipe_min_threshold=1
        accel_profile=2
        accel_speed=0.0
        focus_on_activate=0

        exec-once=${config.home.homeDirectory}/.config/mango/autostart.sh
        EOF
      '';
      rofiRunner = pkgs.writeShellScript "menu.sh" ''
        ${lib.getExe pkgs.rofi} -show drun
      '';
      snipRunner = pkgs.writeShellApplication {
        name = "snip.sh";
        runtimeInputs = with pkgs; [
          grim
          slurp
          wl-clipboard
        ];
        text = ''
          grim -l 0 -g "$(slurp)" - | wl-copy
        '';
      };
    in
    {
      home.packages = with pkgs; [
        brightnessctl
        rofi
        wireplumber
      ];

      services.swww.enable = lib.mkIf hasMango true;
      wayland.windowManager.${if hasMango then "mango" else null} = {
        autostart_sh = ''
          swww img ${myPkgs.tonyWallpaper} &
          ${myPkgs.waybar}/bin/waybar &
        '';
      };

      xdg.configFile = lib.mkIf hasMango {
        "mango/config.conf".source = tonyMangowcConf;
        "mango/menu.sh".source = rofiRunner;
        "mango/snip.sh".source = lib.getExe snipRunner;
      };
    };
}
