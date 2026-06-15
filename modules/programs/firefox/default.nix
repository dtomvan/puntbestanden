{
  flake.modules.homeManager.firefox =
    { pkgs, ... }:
    {
      programs.firefox = {
        enable = true;
        package = pkgs.firefox-devedition;
        profiles.dev-edition-default = {
          isDefault = true;
          userChrome = ''
            TabsToolbar { visibility: collapse !important; }
          '';
        };
      };
    };
}
