{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.firefox;
in {
  options.firefox = with lib; {
    enable = mkEnableOption "install and configure firefox";
    isPlasma = mkEnableOption "Plasma integration";
  };

  config.programs.firefox = lib.mkIf cfg.enable {
    enable = true;
    nativeMessagingHosts = lib.mkIf cfg.isPlasma (with pkgs; [
      kdePackages.plasma-browser-integration
    ]);
    policies = {
      DisableAppUpdate = true;
      DisableFeedbackCommands = true;
      # I need to find some other way to sync tabs and such...
      # DisableFirefoxAccounts = true;
      DisableFirefoxStudies = true;
      DisablePasswordReveal = true;
      DisableSetDesktopBackground = true;
      DisableSystemAddonUpdate = true;
      DisableTelemetry = true;

      Homepage = {
        StartPage = "none";
        URL = "about:blank";
      };

      UserMessaging = {
        ExtensionRecommendations = false;
        FeatureRecommendations = false;
        UrlbarInterventions = false;
        SkipOnboarding = true;
        MoreFromMozilla = false;
        FirefoxLabs = false;
      };
    };

    profiles.default = {
      isDefault = true;
      # search.default = "DuckDuckGo";

      extensions = {
        packages = with pkgs.nur.repos.rycee.firefox-addons; [
          ublock-origin
          sidebery
          darkreader
          sponsorblock
          dearrow
          plasma-integration
          enhancer-for-youtube

          steam-database
        ];
      };

      settings = {
        "widget.use-xdg-desktop-portal.file-picker" = lib.mkIf cfg.isPlasma 1;
        "extensions.autoDisableScopes" = 0;
        "extensions.activeThemeID" = "default-theme@mozilla.org";

        "browser.search.region" = "NL";
        "browser.search.isUS" = false;
        "distribution.searchplugins.defaultLocale" = "nl-NL";
        "general.useragent.locale" = "nl-NL";
        "browser.bookmarks.showMobileBookmarks" = true;

        # Don't fuckin' pull this shit again firefox
        "browser.engagement.ctrlTab.has-used" = true;
        "browser.engagement.downloads-button.has-used" = true;
        "browser.engagement.fxa-toolbar-menu-button.has-used" = true;
        "browser.newtabpage.enabled" = false;
        "browser.discovery.enabled" = false;
        "trailhead.firstrun.didSeeAboutWelcome" = true;
      };

      extraConfig = ''
        lockPref("trailhead.firstrun.branches", "nofirstrun-empty");
        lockPref("browser.aboutwelcome.enabled", false);
      '';

      bookmarks = [
        {
          toolbar = true;
          bookmarks = [
            {
              name = "about:config";
              url = "about:config";
            }
            {
              name = "zermelo";
              url = "https://nassau.zportal.nl/app/";
            }
            {
              name = "OneDrive";
              url = "https://nassauvincent-my.sharepoint.com/personal/129102_nassauvincent_nl1/_layouts/15/onedrive.aspx";
            }
            {
              name = "nixpkgs";
              url = "https://github.com/NixOS/nixpkgs/";
            }
            {
              name = "PaperCut Login for Dr. Nassau College";
              url = "http://as-papercut-as:9191/user";
            }
          ];
        }
      ];
    };
  };
}
