{
  flake.modules.homeManager.firefox =
    {
      pkgs,
      ...
    }:
    let
      privacySettings = {
        # clear all history, cookies, site data every time
        "privacy.sanitize.sanitizeOnShutdown" = true;
        # don't keep any passwords around
        "services.sync.engine.passwords" = false;
        "signon.rememberSignons" = false;
        # private window by default
        "browser.privatebrowsing.autostart" = true;
        # ask not to track
        "privacy.globalprivacycontrol.enabled" = true;
      };
    in
    {
      programs.firefox = {
        # to test YT adblock restrictions with. Clean profile at all times.
        profiles.ubo-only = {
          id = 1;
          bookmarks.force = true;
          bookmarks.settings = [ ];
          extensions = with pkgs.nur.repos.rycee.firefox-addons; {
            packages = [
              ublock-origin
            ];

            force = true;
          };

          settings = privacySettings;
        };

        # control group
        profiles.empty = {
          id = 2;
          bookmarks.force = true;
          bookmarks.settings = [ ];
          extensions.force = true; # no extensions whatsoever
          settings = privacySettings;
        };
      };
    };
}
