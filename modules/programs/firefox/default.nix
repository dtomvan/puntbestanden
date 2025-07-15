{
  flake.modules.homeManager.firefox = {
    config.programs.firefox = {
      enable = true;
      profiles.default = {
        isDefault = true;
        userChrome = ''
          TabsToolbar { visibility: collapse !important; }
        '';
      };
    };
  };
}
