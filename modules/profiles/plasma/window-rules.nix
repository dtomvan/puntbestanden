{
  flake.modules.homeManager.profiles-plasma =
    { lib, ... }:
    {
      programs.plasma = {
        window-rules =
          let
            inherit (lib)
              attrValues
              mapAttrs
              mapAttrs'
              nameValuePair
              ;

            mkDesktopFileFix' =
              wmclass: desktopfile:
              nameValuePair wmclass {
                description = "Set ${wmclass} to ${desktopfile}.desktop";
                match.window-class.value = wmclass;
                apply.desktopfile = {
                  value = desktopfile;
                  apply = "force";
                };
              };
            # Allows correct icons to display in panel when the window class does not
            # match the desktop file name
            # Usage: mkDesktopFileFix { wmclass = "actual-desktop-name"; wmclass2 = "correction2"; }
            mkDesktopFileFix = m: attrValues (mapAttrs' mkDesktopFileFix' m);
          in
          mkDesktopFileFix {
            "firefox-devedition firefox-dev" = "firefox-devedition";
          }
          ++ [
            {
              description = "make overlayed work correctly";
              match.window-class.value = "overlayed";
              apply =
                mapAttrs
                  (_n: r: {
                    value = r;
                    apply = "force";
                  })
                  {
                    desktops = "\\\\0"; # always on all desktops
                    ignoregeometry = true;
                    maximizehoriz = true;
                    maximizevert = true;
                    noborder = true;
                    position = "0,0";
                  };
            }
          ];
      };
    };
}
