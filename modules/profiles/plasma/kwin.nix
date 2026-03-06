{
  flake.modules.homeManager.profiles-plasma =
    { lib, ... }:
    {
      programs.plasma = {
        configFile.kwinrc = {
          ElectricBorders.BottomRight = "ShowDesktop";
          TabBox.LayoutName = "compact";
          TabBox.OrderMinimizedMode = 1;
          Windows.RollOverDesktops = true;
          Xwayland.Scale = lib.mkDefault 1;
        };
        kwin = {
          virtualDesktops.number = 4;
          effects = {
            blur.enable = false;
            # dimInactive.enable = true; # looks bad with overlayed
            minimization.animation = "magiclamp";
            shakeCursor.enable = false;
            translucency.enable = false;
            windowOpenClose.animation = "scale";
          };
        };
      };
    };
}
