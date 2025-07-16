# This module just sets a bunch of firefox policies. The rest of my config is
# user-specific. This one is a blanket "I don't care about your bullshit"
# statement to Mozilla.
{ lib, ... }:
{
  flake.modules.homeManager.firefox = {
    programs.firefox = lib.mapAttrs (_n: lib.mkDefault) {
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

    };
  };
}
