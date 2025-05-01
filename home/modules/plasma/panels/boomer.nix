[
  {
    location = "bottom";
    hiding = "dodgewindows";
    lengthMode = "fit";
    opacity = "adaptive";
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
            "applications:firefox-developer-edition.desktop"
            "applications:org.kde.dolphin.desktop"
            "file:///var/lib/flatpak/exports/share/applications/org.kde.neochat.desktop"
            "applications:org.kde.kate.desktop"
            "file:///var/lib/flatpak/exports/share/applications/org.telegram.desktop.desktop"
          ];
        };
      }
    ];
  }
  {
    location = "left";
    hiding = "autohide";
    lengthMode = "fit";
    opacity = "opaque";
    widgets = [
      "org.kde.plasma.systemtray"
      "org.kde.plasma.digitalclock"
    ];
  }
]
