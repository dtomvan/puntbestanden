{ lib, pkgs, host, ... }:
let
  wallpaper = pkgs.nixos-artwork.wallpapers.nineish-dark-gray.passthru.kdeFilePath;
  fixedWidth = {
    family = "afio";
    pointSize = 12;
  };
in
{
  programs.plasma = {
    enable = true;

    workspace = {
      lookAndFeel = "org.kde.breezedark.desktop";
      cursor = {
        theme = "Breeze";
        size = 24;
      };
      inherit wallpaper;
    };

    kscreenlocker.appearance = { inherit wallpaper; };

    fonts = {
      inherit fixedWidth;
      general = {
        family = "Inter";
        pointSize = 11;
      };
      menu = {
        family = "Inter";
        pointSize = 10;
      };
      small = {
        family = "Inter";
        pointSize = 8;
      };
      toolbar = {
        family = "Inter";
        pointSize = 10;
      };
    };

    hotkeys.commands."alacritty" = {
      name = "Launch Alacritty";
      key = "Meta+Return";
      command = "alacritty";
    };

    hotkeys.commands."tofi-drun" = {
      name = "Launch Tofi";
      key = "Meta+Return";
      command = "tofi-drun --drun-launch=true";
    };

    panels = [
      {
        location = "bottom";
        hiding = "dodgewindows";
        lengthMode = "fit";
        opacity = "adaptive";
        widgets = [
          {
            kickoff = {
              sortAlphabetically = true;
              icon = "nix-snowflake-white";
            };
          }
          "org.kde.plasma.pager"
          {
            iconTasks = {
              launchers = [
                "applications:firefox-developer-edition.desktop"
                "applications:org.kde.dolphin.desktop"
                "file:///var/lib/flatpak/exports/share/applications/org.kde.neochat.desktop"
                "applications:org.kde.kate.desktop"
                "file:///var/lib/flatpak/exports/share/applications/org.telegram.desktop.desktop"
              ];
            };
          }
        ];
      }
      {
        location = "left";
        hiding = "autohide";
        lengthMode = "fit";
        opacity = "opaque";
        widgets = [
          "org.kde.plasma.systemtray"
          "org.kde.plasma.digitalclock"
        ];
      }
    ];

    krunner.shortcuts.launch = [
      "Alt+Space"
      "Meta+Space"
    ];

    shortcuts = {
      kwin = {
        "Switch to Desktop 1" = "Meta+1,,Switch to Desktop 1";
        "Switch to Desktop 2" = "Meta+2,,Switch to Desktop 2";
        "Switch to Desktop 3" = "Meta+3,,Switch to Desktop 3";
        "Switch to Desktop 4" = "Meta+4,,Switch to Desktop 4";
        "Switch to Desktop 5" = "Meta+5,,Switch to Desktop 5";
        "Switch to Desktop 6" = "Meta+6,,Switch to Desktop 6";
        "Switch to Desktop 7" = "Meta+7,,Switch to Desktop 7";
        "Switch to Desktop 8" = "Meta+8,,Switch to Desktop 8";
        "Switch to Desktop 9" = "Meta+9,,Switch to Desktop 9";
        "Window Close" = [
          "Meta+Q"
          "Alt+F4,Alt+F4,Close Window"
        ];
        "Window to Desktop 1" = "Meta+!,,Window to Desktop 1";
        "Window to Desktop 2" = "Meta+@,,Window to Desktop 2";
        "Window to Desktop 3" = "Meta+#,,Window to Desktop 3";
        "Window to Desktop 4" = "Meta+$,,Window to Desktop 4";
        "Window to Desktop 5" = "Meta+%,,Window to Desktop 5";
        "Window to Desktop 6" = "Meta+^,,Window to Desktop 6";
        "Window to Desktop 7" = "Meta+&,,Window to Desktop 7";
        "Window to Desktop 8" = "Meta+*,,Window to Desktop 8";
        "Window to Desktop 9" = "Meta+(,,Window to Desktop 9";
      };
      plasmashell = {
        "activate application launcher" = [
          "Alt+F1,Meta"
          "Alt+F1,Activate Application Launcher"
        ];
        "activate task manager entry 1" = "none,Meta+1,Activate Task Manager Entry 1";
        "activate task manager entry 10" = "none,,Activate Task Manager Entry 10";
        "activate task manager entry 2" = "none,Meta+2,Activate Task Manager Entry 2";
        "activate task manager entry 3" = "none,Meta+3,Activate Task Manager Entry 3";
        "activate task manager entry 4" = "none,Meta+4,Activate Task Manager Entry 4";
        "activate task manager entry 5" = "none,Meta+5,Activate Task Manager Entry 5";
        "activate task manager entry 6" = "none,Meta+6,Activate Task Manager Entry 6";
        "activate task manager entry 7" = "none,Meta+7,Activate Task Manager Entry 7";
        "activate task manager entry 8" = "none,Meta+8,Activate Task Manager Entry 8";
        "activate task manager entry 9" = "none,Meta+9,Activate Task Manager Entry 9";
      };
      "services/systemsettings.desktop"."_launch" = [
        "Tools"
        "Meta+I"
      ];
    };

    powerdevil.battery = {
      dimDisplay = {
        enable = true;
        idleTimeout = 300; # 5 minutes
      };
      turnOffDisplay = {
        idleTimeout = 480; # 8 minutes
      };
      autoSuspend = {
        action = "sleep";
        idleTimeout = 600; # 10 minutes
      };
    };

    kwin = {
      virtualDesktops.number = 4;
      effects = {
        blur.enable = false;
        dimInactive.enable = true;
        minimization.animation = "magiclamp";
        shakeCursor.enable = false;
        translucency.enable = false;
        windowOpenClose.animation = "scale";
      };
    };

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
      "kdeglobals"."General"."AccentColor" = "61,174,233";
      "kdeglobals"."General"."LastUsedCustomAccentColor" = "61,174,233";
      "kdeglobals"."General"."XftAntialias" = true;
      "kdeglobals"."General"."XftHintStyle" = "hintfull";
      "kdeglobals"."General"."XftSubPixel" = "rgb";
      "klaunchrc"."BusyCursorSettings"."Bouncing" = false;
      "klaunchrc"."FeedbackStyle"."BusyCursor" = false;
      "kscreenlockerrc"."Daemon"."LockGrace" = 30;
      "kscreenlockerrc"."Daemon"."Timeout" = 15;
      "kwinrc"."ElectricBorders"."BottomRight" = "ShowDesktop";
      "kwinrc"."TabBox"."LayoutName" = "compact";
      "kwinrc"."TabBox"."OrderMinimizedMode" = 1;
      "kwinrc"."Windows"."RollOverDesktops" = true;
      "kwinrc"."Xwayland"."Scale" = if host.hostName == "feather" then 1.5 else 1;
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

  programs.kate = {
    enable = true;
    editor.font = fixedWidth;
  };

  programs.konsole = {
    enable = true;
    customColorSchemes.catppuccin-mocha = ./catppuccin-mocha.colorscheme;
    defaultProfile = "Catppuccin";
    profiles.Catppuccin = {
      colorScheme = "catppuccin-mocha";
      command = "${lib.getExe pkgs.bashInteractive}";
      font = {
        name = fixedWidth.family;
        size = fixedWidth.pointSize + 2; # because konsole renders smaller for some reason
      };
    };
  };

  programs.okular = {
    enable = true;
    general = {
      openFileInTabs = true;
    };
  };
}
