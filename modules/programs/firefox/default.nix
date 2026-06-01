{
  flake.modules.homeManager.firefox =
    { config, pkgs, ... }:
    {
      programs.firefox = {
        enable = true;
        package = pkgs.firefox-devedition;
        configPath = "${config.xdg.configHome}/mozilla/firefox";
        profiles.dev-edition-default = {
          isDefault = true;
          userChrome = ''
            TabsToolbar { visibility: collapse !important; }
          '';
        };
      };
    };
}
