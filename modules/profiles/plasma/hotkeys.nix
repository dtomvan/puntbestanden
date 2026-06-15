{
  flake.modules.maid.profiles-plasma.kconfig.settings.kglobalshortcutsrc = {
    kwin = {
      "Switch to Desktop 1" = "Meta+1,,";
      "Switch to Desktop 2" = "Meta+2,,";
      "Switch to Desktop 3" = "Meta+3,,";
      "Switch to Desktop 4" = "Meta+4,,";
      "Window Close" = "Meta+Q\tAlt+F4\\,Alt+F4\\,Close Window,,";
      "Window to Desktop 1" = "Meta+!,,";
      "Window to Desktop 2" = "Meta+@,,";
      "Window to Desktop 3" = "Meta+#,,";
      "Window to Desktop 4" = "Meta+$,,";
    };
    plasmashell = {
      "activate application launcher" = "Alt+F1\tMeta,,";
      "activate task manager entry 1" = "none,,";
      "activate task manager entry 2" = "none,,";
      "activate task manager entry 3" = "none,,";
      "activate task manager entry 4" = "none,,";
    };
    services = {
      "org.kde.krunner.desktop"._launch = "Alt+Space\tMeta+Space";
      "systemsettings.desktop"._launch = "Tools\tMeta+I";
      "foot.desktop"._launch = "Meta+Return";
    };
  };
}
