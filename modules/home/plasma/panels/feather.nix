{
  flake.modules.homeManager.plasma-feather = {
    programs.plasma.panels = [
      {
        location = "top";
        hiding = "normalpanel";
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
                "file:///var/lib/flatpak/exports/share/applications/org.telegram.desktop.desktop"
              ];
            };
          }
          "org.kde.plasma.marginsseparator"
          "org.kde.plasma.systemtray"
          "org.kde.plasma.digitalclock"
        ];
      }
    ];
  };
}
