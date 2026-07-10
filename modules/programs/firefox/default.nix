{
  flake.modules.homeManager.firefox =
    { inputs', ... }:
    {
      programs.firefox = {
        enable = true;
        package = inputs'.nixpkgs-firefox.legacyPackages.firefox-devedition;
        profiles.dev-edition-default = {
          isDefault = true;
          userChrome = ''
            TabsToolbar { visibility: collapse !important; }
          '';
        };
      };
    };
}
