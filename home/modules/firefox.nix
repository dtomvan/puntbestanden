{
  config,
  pkgs,
  lib,
  host,
  ...
}:
let
  hostname = host.hostName;
  cfg = config.firefox;
  profile-name = "default";
  # used to make a fake firefox wrapper so for example devedition is happy with
  # my "normal" firefox profile...
  makeFakeFirefox =
    firefox:
    lib.makeOverridable (
      {
        args,
        ...
      }:
      pkgs.stdenvNoCC.mkDerivation {
        pname = "firefox-devedition-wrapped";
        version = "0-unstable-2025-04-13";
        src = firefox;

        nativeBuildInputs = with pkgs; [
          desktop-file-utils
        ];

        installPhase = ''
          mkdir -p $out/share/applications
          cp $src/share/applications/${firefox.meta.mainProgram}.desktop $out/share/applications
          ln -s $src/share/icons $out/share/icons
          desktop-file-edit \
            --set-key="Exec" --set-value="${lib.getExe firefox} ${args} %U" \
            $out/share/applications/${firefox.meta.mainProgram}.desktop
        '';
      }
    );
in
{
  options.firefox = with lib; {
    enable = mkEnableOption "install and configure firefox";
    isPlasma = mkEnableOption "Plasma integration";
  };

  config.programs.firefox = lib.mkIf cfg.enable {
    enable = true;
    # Use official developer edition build so I can use my precious from-source
    # obsidian-web-clipper.
    package = makeFakeFirefox pkgs.firefox-devedition-bin {
      args = "-P ${profile-name}";
    };
    nativeMessagingHosts = lib.mkIf cfg.isPlasma (
      with pkgs;
      [
        kdePackages.plasma-browser-integration
      ]
    );
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

    profiles.${profile-name} = {
      isDefault = true;
      # only reason I did this is because for some reason this never works after using firefox for a moment
      # search.default = "DuckDuckGo";

      extensions = with pkgs.nur.repos.rycee.firefox-addons; {
        packages =
          [
            sponsorblock
            dearrow
            plasma-integration
            enhancer-for-youtube # unfree, cannot build from source :(

            # drv in-tree, overlayed
            pkgs.keepassxc-browser
            pkgs.darkreader
            pkgs.obsidian-web-clipper
            pkgs.sidebery
            pkgs.steam-database
            pkgs.ublock-origin
          ]
          ++ lib.optionals (hostname == "feather") [
            onetab # unfree, cannot build from source :(
          ]
          ++ lib.optionals (hostname == "boomer") [
            pkgs.zotero-connector
            pkgs.violentmonkey
          ];

        force = true;
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

        # PLEASE let me install addons from source FF (only possible on
        # devedition even)
        "xpinstall.signatures.required" = false;
        "extensions.langpacks.signatures.required" = false;

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
                url = "https://cloud.omeduostuurcentenneef.nl";
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
                url = "https://github.com/NixOS/nixpkgs/pulls?q=is%3Aopen+is%3Apr+-is%3Adraft+review%3Anone+sort%3Acreated-asc+-label%3A%222.status%3A+work-in-progress%22+-label%3A%222.status%3A+merge+conflict%22+-label%3A%222.status%3A+stale%22+";
              }
            ]
            ++ (builtins.map
              (v: {
                name = v;
                url = "https://www.examenblad.nl/2024/vwo/vakken/exacte-vakken/${v}";
              })
              [
                "biologie-vwo"
                "natuurkunde-vwo"
                "scheikunde-vwo"
                "wiskunde-b-vwo"
              ]
            )
            ++ (builtins.map
              (v: {
                name = v;
                url = "https://www.examenblad.nl/2024/vwo/vakken/talen/${v}";
              })
              [
                "engels-vwo"
                "frans-vwo"
                "griekse-taal-cultuur-vwo"
                "nederlands-vwo"
              ]
            );
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
