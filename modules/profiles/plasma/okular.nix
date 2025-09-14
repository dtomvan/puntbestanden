{
  flake.modules.homeManager.profiles-plasma = {
    programs.okular = {
      enable = true;
      general = {
        openFileInTabs = true;
      };
    };
  };
}
