{
  flake.modules.homeManager.plasma-boomer = {
    programs.plasma.panels = [
      {
        location = "bottom";
        hiding = "dodgewindows";
        lengthMode = "fill";
        opacity = "opaque";
        widgets = [
          {
            kickoff = {
              sortAlphabetically = true;
              icon = "nix-snowflake-white";
            };
          }
          "org.kde.plasma.pager"
          {
            iconTasks = {
              launchers = [
                "applications:firefox-devedition.desktop"
                "applications:org.kde.dolphin.desktop"
                "applications:org.kde.kate.desktop"
                "applications:org.telegram.desktop.desktop"
                "applications:duo.desktop"
              ];
            };
          }
        ];
      }
      {
        location = "top";
        hiding = "dodgewindows";
        lengthMode = "fill";
        opacity = "opaque";
        widgets = [
          "org.kde.plasma.systemtray"
          "org.kde.plasma.marginsseparator"
          "org.kde.plasma.digitalclock"
        ];
      }
    ];
  };
}
