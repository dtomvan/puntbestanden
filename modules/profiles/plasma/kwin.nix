{
  flake.modules.homeManager.plasma = {
    programs.plasma = {
      kwin = {
        virtualDesktops.number = 4;
        effects = {
          blur.enable = false;
          dimInactive.enable = true;
          minimization.animation = "magiclamp";
          shakeCursor.enable = false;
          translucency.enable = false;
          windowOpenClose.animation = "scale";
        };
      };
    };
  };
}
