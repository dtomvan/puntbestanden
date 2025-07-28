let
  url = "https://fs.omeduostuurcentenneef.nl/drop/";
in
{
  flake.webApps.copyparty_omeduo = {
    name = "Omeduo drop";
    inherit url;
    icon = ./favicon.png;
    genericName = "copyparty Instance";
  };

  # yeahhh I guess this is the best place for this
  flake.modules.homeManager.profiles-base =
    { pkgs, ... }:
    {
      home.packages = [
        (pkgs.writeShellApplication {
          name = "duo";

          runtimeInputs = with pkgs; [
            coreutils
            curl
            gawk
            gnugrep
            libnotify
            wl-clipboard
          ];

          text = ''
            if ! wl-paste -l | grep '^image/'; then
              echo not an image
              notify-send duo "not an image"
              exit 1
            fi

            extension="$(wl-paste | file -b --extension - | awk -F/ '{ print $1 }')"
            wl-paste \
              | curl -sT- ${url}."$extension"?want=url \
              | tee >(wl-copy)

            sleep .5

            notify-send duo "successfully uploaded to $(wl-paste | tr -dc '[:print:]')"
          '';
        })
      ];

      xdg.desktopEntries.duo = {
        name = "Duo";
        comment = "Upload screenshot to omeduostuurcentenneef.nl";
        exec = "duo";
        icon = ./favicon.png;
        terminal = false;
      };
    };
}
