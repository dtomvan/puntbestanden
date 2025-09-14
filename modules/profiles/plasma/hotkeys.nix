{
  flake.modules.homeManager.profiles-plasma = {
    programs.plasma = {
      krunner.shortcuts.launch = [
        "Alt+Space"
        "Meta+Space"
      ];
      shortcuts = {
        "services/Alacritty.desktop".New = "Meta+Return";
        kwin = {
          "Switch to Desktop 1" = "Meta+1";
          "Switch to Desktop 2" = "Meta+2";
          "Switch to Desktop 3" = "Meta+3";
          "Switch to Desktop 4" = "Meta+4";
          "Switch to Desktop 5" = "Meta+5";
          "Switch to Desktop 6" = "Meta+6";
          "Switch to Desktop 7" = "Meta+7";
          "Switch to Desktop 8" = "Meta+8";
          "Switch to Desktop 9" = "Meta+9";
          "Window Close" = [
            "Meta+Q"
            "Alt+F4,Alt+F4,Close Window"
          ];
          "Window to Desktop 1" = "Meta+!";
          "Window to Desktop 2" = "Meta+@";
          "Window to Desktop 3" = "Meta+#";
          "Window to Desktop 4" = "Meta+$";
          "Window to Desktop 5" = "Meta+%";
          "Window to Desktop 6" = "Meta+^";
          "Window to Desktop 7" = "Meta+&";
          "Window to Desktop 8" = "Meta+*";
          "Window to Desktop 9" = "Meta+(";
        };
        plasmashell = {
          "activate application launcher" = [
            "Alt+F1"
            "Meta"
          ];
          "activate task manager entry 1" = "none";
          "activate task manager entry 10" = "none";
          "activate task manager entry 2" = "none";
          "activate task manager entry 3" = "none";
          "activate task manager entry 4" = "none";
          "activate task manager entry 5" = "none";
          "activate task manager entry 6" = "none";
          "activate task manager entry 7" = "none";
          "activate task manager entry 8" = "none";
          "activate task manager entry 9" = "none";
        };
        "services/systemsettings.desktop"."_launch" = [
          "Tools"
          "Meta+I"
        ];
      };

    };
  };
}
