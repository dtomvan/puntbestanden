{
  flake.modules.homeManager.firefox = {
    programs.firefox.profiles.default = {
      settings = {
        "widget.use-xdg-desktop-portal.file-picker" = 1;
        "extensions.autoDisableScopes" = 0;
        "extensions.activeThemeID" = "default-theme@mozilla.org";
        "general.autoScroll" = true;

        # native vertical tabs!
        "sidebar.verticalTabs" = true;
        "sidebar.revamp" = true;

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
        "browser.engagement.sidebar-button.has-used" = true;
        "browser.engagement.home-button.has-used" = true;
        "browser.engagement.library-button.has-used" = true;
        "sidebar.notification.badge.aichat" = false;
        "browser.ml.chat.sidebar" = false;
        "sidebar.verticalTabs.dragToPinPromo.dismissed" = true;
        "sidebar.new-sidebar.has-used" = true;
        "browser.newtabpage.enabled" = false;
        "browser.discovery.enabled" = false;
        "browser.tabs.groups.smart.userEnabled" = false; # don't use AI for tab group names bruh...
        "browser.newtabpage.activity-stream.showSponsoredCheckboxes" = false;
        "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
        "trailhead.firstrun.didSeeAboutWelcome" = true;
        "browser.translations.automaticallyPopup" = false;
        "browser.urlbar.suggest.trending" = false; # "trending search suggestions" fuck off

        # don't track me please
        "privacy.globalprivacycontrol.enabled" = true;

        # disable "quick actions" during search
        "browser.urlbar.suggest.quickactions" = false;
      };

      extraConfig = ''
        lockPref("trailhead.firstrun.branches", "nofirstrun-empty");
        lockPref("browser.aboutwelcome.enabled", false);
      '';

    };
  };
}
