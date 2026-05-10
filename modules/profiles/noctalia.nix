{
  self,
  lib,
  inputs,
  ...
}:
{
  flake-file.inputs.noctalia-shell = {
    url = "github:noctalia-dev/noctalia-shell/v4.7.6";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  nixConfig = {
    extra-substituters = [ "https://noctalia.cachix.org" ];
    extra-trusted-public-keys = [
      "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
    ];
  };

  flake.modules.nixos.profiles-noctalia =
    { inputs', config, ... }:
    {
      assertions = [
        {
          assertion = !config.services.displayManager.dms-greeter.enable;
          message = "noctalia conflicts with dms";
        }
      ];
      imports = [ self.modules.nixos.programs-niri-common ];

      programs.regreet = {
        enable = true;
        settings.GTK.application_prefer_dark_theme = true;
      };

      environment.systemPackages = lib.singleton inputs'.noctalia-shell.packages.default;

      # recommended by docs
      networking.networkmanager.enable = lib.mkDefault true;
      hardware.bluetooth.enable = lib.mkDefault true;
      services.power-profiles-daemon.enable = lib.mkDefault true;
      services.upower.enable = lib.mkDefault true;
    };

  flake.modules.homeManager.profiles-noctalia =
    { config, pkgs, ... }:
    {
      assertions = [
        {
          assertion = !((config.programs.dms-shell or { }).enable or false);
          message = "noctalia conflicts with dms";
        }
      ];

      imports = [
        inputs.noctalia-shell.homeModules.default
        self.modules.homeManager.programs-niri-common
      ];

      programs.noctalia-shell = {
        enable = true;
        package = null;
        # TODO: seperate files (per section) also minimize
        settings = {
          settingsVersion = 0;
          bar = {
            showCapsule = false;
            backgroundOpacity = 1;
            frameRadius = 0;
            outerCorners = false;
            hideOnOverview = true;

            displayMode = "always_visible"; # TODO: dodge windows?
            autoHideDelay = 500;
            autoShowDelay = 150;

            widgets = {
              left = [
                {
                  id = "ControlCenter";
                  customIconPath = "${pkgs.nixos-icons}/share/icons/hicolor/128x128/apps/nix-snowflake-white.png";
                }
                {
                  id = "Workspace";
                }
                {
                  id = "Clock";
                  formatHorizontal = "hh:mm\\nyyyy-MM-dd";
                  formatVertical = "HH mm";
                  useMonospacedFont = true;
                  usePrimaryColor = true;
                }
                {
                  id = "ActiveWindow";
                  showIcon = false;
                  maxWidth = 500;
                }
                {
                  id = "MediaMini";
                  maxWidth = 500;
                }
              ];
              center = [ ];
              right = [
                {
                  id = "Tray";
                  colorizeIcons = true;
                  drawerEnabled = false;
                }
                {
                  id = "NotificationHistory";
                }
                {
                  id = "Volume";
                }
                {
                  id = "Battery";
                }
                {
                  id = "SessionMenu";
                }
              ];
            };
            reverseScroll = true;
          };
          general = {
            animationSpeed = 1.5;
            compactLockScreen = true;
            enableShadows = false;
            enableBlurBehind = false;
            showChangelogOnStartup = false;
            telemetryEnabled = false;

            reverseScroll = true;
            smoothScrollEnabled = true;
          };
          ui.panelBackgroundOpacity = 1;
          location = {
            weatherEnabled = false;
            use12hourFormat = false;
            showWeekNumberInCalendar = true;
            showCalendarWeather = false;
            firstDayOfWeek = 1; # monday
            autoLocate = false;
          };
          calendar = {
            cards = [
              {
                enabled = true;
                id = "calendar-header-card";
              }
              {
                enabled = true;
                id = "calendar-month-card";
              }
            ];
          };
          wallpaper = {
            viewMode = "single";
            fillMode = "crop";
            skipStartupTransition = true;
          };
          controlCenter = {
            shortcuts = {
              left = [
                {
                  id = "Network";
                }
                {
                  id = "Bluetooth";
                }
                {
                  id = "NoctaliaPerformance";
                }
              ];
              right = [
                {
                  id = "Notifications";
                }
                {
                  id = "PowerProfile";
                }
                {
                  id = "KeepAwake";
                }
                {
                  id = "NightLight";
                }
              ];
            };
            cards = [
              {
                enabled = true;
                id = "shortcuts-card";
              }
              {
                enabled = true;
                id = "audio-card";
              }
              {
                enabled = false;
                id = "brightness-card";
              }
              {
                enabled = true;
                id = "media-sysmon-card";
              }
            ];
          };
          dock.enabled = false;
          network.networkPanelView = "wifi";
          notifications = {
            enabled = true;
            enableMarkdown = false; # TODO: useful?
            sounds.enabled = true;
          };
          colorSchemes = {
            useWallpaperColors = false; # TODO: true?
          };
          nightLight.autoSchedule = true;
          idle = {
            enabled = true;
            screenOffTimeout = 10 * 60;
            lockTimeout = 11 * 60;
            suspendTimeout = 30 * 60;
            fadeDuration = 5;
          };
        };
      };
    };

  flake.modules.homeManager."tomvd@boomer".programs.noctalia-shell.settings.idle.suspendTimeout =
    lib.mkForce 0;
}
