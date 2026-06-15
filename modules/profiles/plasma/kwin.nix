{
  flake.modules.maid.profiles-plasma =
    { lib, ... }:
    {
      kconfig.settings.kwinrc = {
        ElectricBorders.BottomRight = "ShowDesktop";
        Xwayland.Scale = lib.mkDefault 1;
        Desktops.Number = 4;
        Plugins = {
          blurEnabled = false;
          fadeEnabled = false;
          glideEnabled = false;
          magiclampEnabled = true;
          scaleEnabled = true;
          shakecursorEnabled = false;
          squashEnabled = false;
          translucencyEnabled = false;
        };
        TabBox = {
          LayoutName = "compact";
          OrderMinimizedMode = 1;
        };
        Windows = {
          RollOverDesktops = true;
        };
      };
    };
}
