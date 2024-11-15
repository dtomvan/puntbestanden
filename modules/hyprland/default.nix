args @ {
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.modules.hyprland;
  agsCfg = config.modules.ags;
in {
  imports = [
    ../terminals
  ];

  options.modules.hyprland = with lib; {
    enable = mkEnableOption "download and configure hyprland";
    use-nix-colors = mkEnableOption "use nix-colors for colorscheme";
    extra-keymaps = mkOption {
      description = "any extra keymaps to set";
      type = with types; listOf str;
    };
  };

  config = let
    terminal-app = config.modules.terminals.bin;
  in
    lib.mkIf cfg.enable {
      xdg.configFile."hypr/swaylock.cfg".source = ./swaylock.cfg;
      xdg.configFile."hypr/bluelight.frag".source = ./bluelight.frag;
      xdg.configFile."tofi/config".text =
        ''
          width = 100%
          height = 100%
          border-width = 0
          outline-width = 0
          padding-left = 35%
          padding-top = 35%
          result-spacing = 25
          num-results = 5
          font = monospace
          background-color = #000A
          terminal = ${terminal-app}
        ''
        + lib.optionalString (cfg.use-nix-colors) ''
          selection-color = #${config.colorScheme.palette.base0D}
        '';

      # terminal is required!
      modules.terminals.enable = lib.mkForce true;
      wayland.windowManager.hyprland.enable = true;
      services.playerctld.enable = true;
      wayland.windowManager.hyprland.settings = let
        tools = import ./tools.nix args;
        wsKeys = builtins.concatLists (builtins.genList (
            i: let
              ws = i + 1;
            in [
              "$mod, code:1${toString i}, workspace, ${toString ws}"
              "$mod SHIFT, code:1${toString i}, movetoworkspace, ${toString ws}"
            ]
          )
          9);
        windowKeys = [
          "$mod, H, movefocus, l"
          "$mod, L, movefocus, r"
          "$mod, K, movefocus, u"
          "$mod, J, movefocus, d"
          "$mod, 0, togglespecialworkspace,"
          "$mod SHIFT, 0, movetoworkspace, special"
          "$mod SHIFT, F, fullscreenstate,-1 2"
          "$mod, C, killactive,"
          "$mod, F, fullscreen,0"
          "$mod, M, fullscreen,1"
          "$mod, P, pseudo,"
          "$mod, S, togglefloating,"
          "$mod, W, togglesplit,"
          "SUPERALT, M, exit,"
        ];
        audioKeys = with tools; [
          ", XF86AudioPlay, exec, ${playerctl} play-pause"
          ", XF86AudioPrev, exec, ${playerctl} previous"
          ", XF86AudioNext, exec, ${playerctl} next"
        ];
        audioKeysle = with tools; [
          ", XF86AudioRaiseVolume, exec, ${wpctl} set-volume @DEFAULT_AUDIO_SINK@ 5%+"
          ", XF86AudioLowerVolume, exec, ${wpctl} set-volume @DEFAULT_AUDIO_SINK@ 5%-"
        ];
        utilKeys = with tools;
          [
            ''$mod, Print, exec,${grimblast} --notify --freeze copysave area "$HOME/screenshots/screenshot.$(date +%Y%m%d_%H%M%S).png"''
            ''$mod, return, exec, ${terminal-app}''
            ''$mod, space, exec, $(${tofi.drun})''
            ''$mod, V, exec, ${clipman} pick -t CUSTOM -T "${bemenu} --list 10 --wrap"''
            ''$mod SHIFT, escape, exec, ${locker}''
            ''$mod,D,exec, ${desktop-alpha} 0.1; sleep 1; ${desktop-alpha} 1''
            ''$mod,f12,exec,${toggle-nightlight}''
          ]
          ++ lib.optionals agsCfg.enable [''$mod,escape,exec,${tools.ags} -t pmenu''];
        autostart = with tools;
          [
            "${wl-paste} -t text --watch ${clipman} store"
            "${swayidle}"
          ]
          ++ lib.optionals agsCfg.enable ["${tools.ags} run"];
      in
        lib.mkIf cfg.enable {
          monitor = [", preferred, auto, 1"];
          input = {
            kb_layout = "us,gr";
            kb_variant = "euro";
            kb_model = "pc105";
            kb_options = "compose:ralt,grp:alt_caps_toggle";
            follow_mouse = 1;
            touchpad.natural_scroll = true;
            sensitivity = 0;
            force_no_accel = true;
          };
          debug = {
            disable_logs = false;
            enable_stdout_logs = true;
          };
          general = {
            gaps_in = 5;
            gaps_out = 20;
            border_size = 2;
            "col.active_border" =
              if cfg.use-nix-colors
              then "rgb(${config.colorScheme.palette.base05})"
              else "rgba(33ccffee) rgba(00ff99ee) 45deg";
            "col.inactive_border" =
              if cfg.use-nix-colors
              then "rgb(${config.colorScheme.palette.base00})"
              else "rgba(595959aa)";
            layout = "dwindle";
          };
          dwindle = {
            pseudotile = true;
            preserve_split = true;
          };
          decoration = {
            rounding = 10;
          };
          misc = {
            mouse_move_enables_dpms = true;
            key_press_enables_dpms = true;
          };
          cursor.no_hardware_cursors = true;
          animations.enabled = true; # todo what about "myBezier"

          "$mod" = "SUPER";
          bind = wsKeys ++ windowKeys ++ audioKeys ++ utilKeys;
          bindle = audioKeysle;
          bindm = [
            "$mod, mouse:272, movewindow"
            "$mod, mouse:273, resizewindow"
          ];

          exec-once = autostart;
        };
    };
}
