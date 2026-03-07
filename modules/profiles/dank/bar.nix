{ lib, ... }:
{
  flake.modules.homeManager.profiles-dank.programs.dms-shell.settings = {
    showDock = false;
    weatherEnabled = false;
    osdMediaPlaybackEnabled = false;
    launcherLogoMode = "os";
    barConfigs = lib.singleton {
      id = "default";
      name = "Main Bar";
      enabled = true;
      position = 0;
      screenPreferences = [
        "all"
      ];
      showOnLastDisplay = true;
      leftWidgets = [
        "launcherButton"
        "workspaceSwitcher"
        "focusedWindow"
      ];
      centerWidgets = [
        "music"
        "clock"
      ];
      rightWidgets = [
        "systemTray"
        "clipboard"
        "notificationButton"
        "battery"
        "controlCenterButton"
      ];
      spacing = 4;
      innerPadding = 4;
      bottomGap = 0;
      transparency = 0;
      widgetTransparency = 1;
      squareCorners = false;
      noBackground = false;
      gothCornersEnabled = false;
      gothCornerRadiusOverride = false;
      gothCornerRadiusValue = 12;
      borderEnabled = false;
      borderColor = "surfaceText";
      borderOpacity = 1;
      borderThickness = 1;
      widgetOutlineEnabled = false;
      widgetOutlineColor = "primary";
      widgetOutlineOpacity = 1;
      widgetOutlineThickness = 1;
      fontScale = 1;
      autoHide = false;
      autoHideDelay = 250;
      showOnWindowsOpen = false;
      openOnOverview = false;
      visible = true;
      popupGapsAuto = true;
      popupGapsManual = 4;
      maximizeDetection = true;
      scrollEnabled = true;
      scrollXBehavior = "column";
      scrollYBehavior = "workspace";
      shadowIntensity = 0;
      shadowOpacity = 60;
      shadowColorMode = "text";
      shadowCustomColor = "#000000";
    };
  };
}
