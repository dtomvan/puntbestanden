{ config, inputs, ... }:
let
  inherit (config.flake.modules) nixos;
in
{
  flake-file.inputs = {
    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
  };

  flake.modules = {
    nixos.profiles-plasma =
      {
        pkgs,
        lib,
        config,
        ...
      }:
      {
        imports = [ nixos.profiles-graphical ];

        services.displayManager.sddm.enable = lib.mkDefault true;
        services.displayManager.sddm.wayland.enable = lib.mkDefault true;

        services.desktopManager.plasma6.enable = true;
        services.displayManager.defaultSession = "plasma";
        environment.systemPackages =
          with pkgs.kdePackages;
          [
            kdeconnect-kde
            krfb # VNC share/server
            krdc # remote desktop client, should get negotiated by kdeconnect
            plasma-browser-integration

            filelight
            pkgs.haruna
          ]
          ++ lib.optionals config.services.tailscale.enable [ pkgs.ktailctl ]
          ++ lib.optionals config.hardware.sane.enable [ pkgs.kdePackages.skanpage ];
      };

    homeManager.plasma =
      {
        lib,
        pkgs,
        ...
      }:
      let
        wallpaper = pkgs.nixos-artwork.wallpapers.nineish-catppuccin-mocha.passthru.kdeFilePath;
      in
      {
        imports = [
          inputs.plasma-manager.homeManagerModules.plasma-manager
        ];

        programs.plasma = {
          enable = true;

          workspace = {
            lookAndFeel = "org.kde.breezedark.desktop";
            cursor = {
              theme = "default";
              size = 24;
            };
            inherit wallpaper;
          };

          kscreenlocker.appearance = { inherit wallpaper; };

          configFile = {
            krunnerrc = {
              "Plugins"."baloosearchEnabled" = false;
              "Plugins"."browserhistoryEnabled" = false;
              "Plugins"."browsertabsEnabled" = false;
              "Plugins"."calculatorEnabled" = false;
              "Plugins"."helprunnerEnabled" = false;
              "Plugins"."krunner_appstreamEnabled" = false;
              "Plugins"."krunner_bookmarksrunnerEnabled" = false;
              "Plugins"."krunner_charrunnerEnabled" = false;
              "Plugins"."krunner_dictionaryEnabled" = false;
              "Plugins"."krunner_killEnabled" = true;
              "Plugins"."krunner_konsoleprofilesEnabled" = false;
              "Plugins"."krunner_kwinEnabled" = false;
              "Plugins"."krunner_placesrunnerEnabled" = false;
              "Plugins"."krunner_plasma-desktopEnabled" = false;
              "Plugins"."krunner_powerdevilEnabled" = false;
              "Plugins"."krunner_recentdocumentsEnabled" = false;
              "Plugins"."krunner_sessionsEnabled" = false;
              "Plugins"."krunner_shellEnabled" = true;
              "Plugins"."krunner_spellcheckEnabled" = false;
              "Plugins"."krunner_webshortcutsEnabled" = false;
              "Plugins"."locationsEnabled" = true;
              "Plugins"."org.kde.activities2Enabled" = false;
              "Plugins"."unitconverterEnabled" = false;
              "Plugins/Favorites"."plugins" = "krunner_services,krunner_systemsettings";
            };
            "baloofilerc"."General"."exclude folders[$e]" =
              "$HOME/keybase/,$HOME/old-config/,$HOME/projects/,$HOME/puntbestanden/,$HOME/repos/";
            "baloofilerc"."General"."only basic indexing" = true;
            "dolphinrc"."DetailsMode"."PreviewSize" = 32;
            "kcminputrc"."Libinput/9494/127/Cooler Master Technology Inc. Gaming MECH KB Mouse"."PointerAcceleration" =
              "-0.400";
            "kcminputrc"."Libinput/9494/127/Cooler Master Technology Inc. Gaming MECH KB Mouse"."PointerAccelerationProfile" =
              1;
            "kcminputrc"."Libinput/9494/127/Cooler Master Technology Inc. Gaming MECH KB Mouse"."ScrollMethod" =
              4;
            "klaunchrc"."BusyCursorSettings"."Bouncing" = false;
            "klaunchrc"."FeedbackStyle"."BusyCursor" = false;
            "kscreenlockerrc"."Daemon"."LockGrace" = 30;
            "kscreenlockerrc"."Daemon"."Timeout" = 15;
            "kwinrc"."ElectricBorders"."BottomRight" = "ShowDesktop";
            "kwinrc"."TabBox"."LayoutName" = "compact";
            "kwinrc"."TabBox"."OrderMinimizedMode" = 1;
            "kwinrc"."Windows"."RollOverDesktops" = true;
            "kwinrc"."Xwayland"."Scale" = lib.mkDefault 1;
            "kxkbrc"."Layout"."DisplayNames" = ",";
            "kxkbrc"."Layout"."LayoutList" = "us,gr";
            "kxkbrc"."Layout"."Options" = "compose:ralt";
            "kxkbrc"."Layout"."ResetOldOptions" = true;
            "kxkbrc"."Layout"."Use" = true;
            "kxkbrc"."Layout"."VariantList" = ",";
            "plasma-localerc"."Formats"."LANG" = "en_US.UTF-8";
            "plasma-localerc"."Formats"."LC_TIME" = "C";
            "plasmanotifyrc"."Notifications"."PopupPosition" = "BottomRight";
            "plasmanotifyrc"."Notifications"."PopupTimeout" = 10000;
          };
        };
      };
  };
}
