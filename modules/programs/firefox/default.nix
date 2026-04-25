{
  flake.modules.homeManager.firefox =
    { config, ... }:
    {
      programs.firefox = {
        enable = true;
        configPath = "${config.xdg.configHome}/mozilla/firefox";
        profiles.default = {
          isDefault = true;
          userChrome = ''
            TabsToolbar { visibility: collapse !important; }
          '';
        };
      };
    };
}
