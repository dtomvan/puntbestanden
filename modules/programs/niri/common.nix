{
  flake.modules = {
    nixos.programs-niri-common =
      {
        pkgs,
        lib,
        config,
        ...
      }:
      {
        programs.niri.enable = true;

        environment.systemPackages = builtins.attrValues {
          inherit (pkgs)
            pcmanfm
            udiskie
            xwayland-satellite
            ;
        };

        services.udisks2.enable = true;

        qt = lib.mkIf (!config.services.desktopManager.plasma6.enable) {
          enable = true;
          style = "breeze";
          platformTheme = "qt5ct";
        };

        xdg.portal = {
          enable = true;

          extraPortals = builtins.attrValues {
            inherit (pkgs) xdg-desktop-portal-gtk;
            inherit (pkgs.kdePackages) xdg-desktop-portal-kde;
          };

          config = {
            common.default = "kde";
            niri."org.freedesktop.impl.portal.FileChooser" = [ "kde" ];
          };
        };
      };

    homeManager.programs-niri-common =
      { pkgs, ... }:
      {
        home.packages = builtins.attrValues {
          inherit (pkgs)
            wl-clipboard
            brightnessctl
            pipewire
            ;
          inherit (pkgs.nur.repos.dtomvan)
            cclip
            fsel
            ;
          swaylock = pkgs.writeShellScriptBin "swaylock" ''
            B='#00000000' # blank
            C='#ffffff22' # clear ish
            D='#81a1c1cc' # default
            T='#88c0d0ee' # text
            W='#bf616aee' # wrong
            V='#5e81acbb' # verifying
            L='#4c566aaa' # inside

            ${pkgs.swaylock-effects}/bin/swaylock \
                -n \
                --color="#00000000" \
                --inside-ver-color=$C \
                --ring-ver-color=$V \
                \
                --inside-wrong-color=$C \
                --ring-wrong-color=$W \
                \
                --inside-color=$L \
                --ring-color=$D \
                --line-color=$B \
                --separator-color=$D \
                \
                --text-ver-color=$T \
                --text-wrong-color=$T \
                --text-color=$T \
                \
                --key-hl-color=$L \
                --bs-hl-color=$W \
                \
                --clock \
                --indicator \
                --screenshots \
                --timestr="%I:%M:%S %p" \
                --datestr="%A, %d-%m-%Y" \
                --font='AporeticSansM Nerd Font' \
                --font-size=20 \
                --effect-blur=10x3 \
                --fade-in=1
          '';
        };
      };
  };
}
