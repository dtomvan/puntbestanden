# this module basically does tonarchy in nixos. It uses upstream configs which
# sadly can't get mutated because thats not how home-manager works.
{
  flake.modules.nixos.profiles-oxwm =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    {
      services.xserver = {
        enable = true;
        windowManager.oxwm = {
          enable = true;
          package = pkgs.oxwm.overrideAttrs rec {
            version = "0.10.2";
            src = pkgs.fetchFromGitHub {
              owner = "tonybanters";
              repo = "oxwm";
              rev = "7b7d32092b20434e751e74d87e37471b06e6e7c8";
              hash = "sha256-3WP7KXg5eiv8T6PIFrQI7S8iovGsig/wdU1KiLiQGWY=";
            };
            cargoDeps = pkgs.rustPlatform.fetchCargoVendor {
              inherit src;
              hash = "sha256-anCfe+RTEukLblyCuY1LR+Ngykx/mzv/JOIRxZVMVus=";
            };
          };
        };
      };

      environment.sessionVariables = lib.optionalAttrs (config.networking.hostName == "feather") {
        GDK_DPI_SCALE = "1.25";
      };
    };

  flake.modules.homeManager.profiles-oxwm =
    {
      self',
      pkgs,
      lib,
      ...
    }:
    let
      # tonarchyPicomConf = pkgs.fetchurl {
      #   name = "tonarchy-picom.conf";
      #   url = "https://raw.githubusercontent.com/tonybanters/tonarchy/ad5c4629263d5c5e84495dd14e1372411af8a5ed/assets/picom/picom.conf";
      #   hash = "sha256-og2UMhgUOjrzv7Drv93bsr9MnBTODyxfSEhY6xFfG4U=";
      # };
      inherit (self'.packages) tonyWallpaper;

      autostartCommands = [
        # "${lib.getExe pkgs.picom} --config ${tonarchyPicomConf}" # broken
        "${lib.getExe pkgs.xwallpaper} --zoom ${tonyWallpaper}"
      ];
    in
    {
      # required by config
      home.packages = with pkgs; [
        maim
        rofi
        xclip

        brightnessctl
        wireplumber
      ];

      xdg.configFile."oxwm/config.lua".source = pkgs.stdenvNoCC.mkDerivation (finalAttrs: {
        name = "oxwm-config.lua";
        version = "7b7d32092b20434e751e74d87e37471b06e6e7c8";

        src = pkgs.fetchurl {
          url = "https://raw.githubusercontent.com/tonybanters/oxwm/${finalAttrs.version}/templates/tonarchy-config.lua";
          hash = "sha256-Av2J0bYh0GUrX4AeXYKQvr++kOE/nP9qi/d+SjFZWpQ=";
        };

        dontUnpack = true;

        installPhase = ''
          cp $src $out
          chmod +w $out
          ${lib.concatMapStringsSep "\n" (
            c: "printf 'oxwm.autostart(\"%s\")\n' ${lib.escapeShellArg c} >> $out"
          ) autostartCommands}
          cat << EOF >> $out
          oxwm.key.bind({}, "XF86AudioRaiseVolume", oxwm.spawn("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"))
          oxwm.key.bind({}, "XF86AudioLowerVolume", oxwm.spawn("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"))
          oxwm.key.bind({}, "XF86AudioMute", oxwm.spawn("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"))
          oxwm.key.bind({}, "XF86AudioMicMute", oxwm.spawn("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"))
          oxwm.key.bind({}, "XF86MonBrightnessUp", oxwm.spawn("brightnessctl -e4 -n2 set 5%+"))
          oxwm.key.bind({}, "XF86MonBrightnessDown", oxwm.spawn("brightnessctl -e4 -n2 set 5%-"))
          EOF
        '';
      });
    };
}
