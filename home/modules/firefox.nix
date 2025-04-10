{
  config,
  pkgs,
  lib,
  hostname,
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
      DisableFirefoxAccounts = true;
      DisableFirefoxStudies = true;
      DisablePasswordReveal = true;
      DisableSetDesktopBackground = true;
      DisableSystemAddonUpdate = true;
      DisableTelemetry = true;

      OfferToSaveLogins = false;

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
      # only reason I did this is because for some reason this never works after using firefox for a moment
      # search.default = "DuckDuckGo";

      extensions = with pkgs.nur.repos.rycee.firefox-addons; {
        packages =
          [
            ublock-origin
            sidebery
            darkreader
            sponsorblock
            dearrow
            plasma-integration
            enhancer-for-youtube

            keepassxc-browser

            steam-database
            # drv in-tree, overlayed
            pkgs.obsidian-web-clipper
          ]
          ++ lib.optionals (hostname == "tom-laptop") [
            onetab
          ]
          ++ lib.optionals (hostname == "tom-pc") [
            zotero-connector
          ];
      };

      settings = {
        "widget.use-xdg-desktop-portal.file-picker" = lib.mkIf cfg.isPlasma 1;
        "extensions.autoDisableScopes" = 0;
        "extensions.activeThemeID" = "default-theme@mozilla.org";
        "general.autoScroll" = true;

        "browser.search.region" = "NL";
        "browser.search.isUS" = false;
        "distribution.searchplugins.defaultLocale" = "nl-NL";
        "general.useragent.locale" = "nl-NL";
        "browser.bookmarks.showMobileBookmarks" = true;

        "services.sync.engine.passwords" = false;
        "signon.rememberSignons" = false;

        # Don't fuckin' pull this shit again firefox
        "browser.engagement.ctrlTab.has-used" = true;
        "browser.engagement.downloads-button.has-used" = true;
        "browser.engagement.fxa-toolbar-menu-button.has-used" = true;
        "browser.newtabpage.enabled" = false;
        "browser.discovery.enabled" = false;
        "trailhead.firstrun.didSeeAboutWelcome" = true;
        "browser.translations.automaticallyPopup" = false;
      };

      extraConfig = ''
        lockPref("trailhead.firstrun.branches", "nofirstrun-empty");
        lockPref("browser.aboutwelcome.enabled", false);
      '';

      bookmarks.force = true;
      bookmarks.settings = [
        {
          toolbar = true;
          bookmarks =
            [
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
              {
                name = "unreviewed PRs to nixpkgs";
                url = "https://github.com/NixOS/nixpkgs/pulls?utf8=%E2%9C%93&q=is%3Aopen+is%3Apr+-is%3Adraft+review%3Anone+sort%3Acreated-asc+-label%3A%222.status%3A+work-in-progress%22+-label%3A%222.status%3A+merge+conflict%22";
              }
              {
                name = "nixpkgs low-hanging fruit";
                url = "https://github.com/NixOS/nixpkgs/pulls?utf8=%E2%9C%93&q=is%3Aopen+is%3Apr+-is%3Adraft+review%3Anone+sort%3Acreated-asc+-label%3A%222.status%3A+work-in-progress%22+-label%3A%222.status%3A+merge+conflict%22+label%3A%228.has%3A+package+%28update%29%22+comments%3A%3C2+";
              }
            ]
            ++ (builtins.map (v: {
                name = v;
                url = "https://www.examenblad.nl/2024/vwo/vakken/exacte-vakken/${v}";
              }) [
                "biologie-vwo"
                "natuurkunde-vwo"
                "scheikunde-vwo"
                "wiskunde-b-vwo"
              ])
            ++ (builtins.map (v: {
                name = v;
                url = "https://www.examenblad.nl/2024/vwo/vakken/talen/${v}";
              }) [
                "engels-vwo"
                "frans-vwo"
                "griekse-taal-cultuur-vwo"
                "nederlands-vwo"
              ]);
        }
      ];

      userChrome = ''
        TabsToolbar { visibility: collapse !important; }
      '';
      # -- } profiles.default
    };
    # -- } programs.firefox
  };
}
