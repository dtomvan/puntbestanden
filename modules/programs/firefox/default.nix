{
  flake.modules.homeManager.firefox.programs.firefox = {
    enable = true;
    profiles.default = {
      isDefault = true;
      userChrome = ''
        TabsToolbar { visibility: collapse !important; }
      '';
    };
  };
}
