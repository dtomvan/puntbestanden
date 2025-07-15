{
  flake.modules.homeManager.plasma = {
    programs.okular = {
      enable = true;
      general = {
        openFileInTabs = true;
      };
    };
  };
}
