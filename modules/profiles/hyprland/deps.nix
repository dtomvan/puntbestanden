{
  flake.modules = {
    nixos.hyprland =
      { pkgs, ... }:
      {
        # sensible defaults for when the config was manually written, HM could
        # do this also but whatever
        environment.systemPackages = with pkgs; [
          # Some KDE apps which get added to plasma automatically, but which I also want on Hyprland
          haruna
          kdePackages.ark
          kdePackages.dolphin
          kdePackages.kate
          kdePackages.okular

          kdePackages.breeze-gtk
          kdePackages.breeze-icons

          brightnessctl
          clipse
          fnott
          grimblast
          kdePackages.xwaylandvideobridge
          playerctl
          quickshell
          socat
          wireplumber
        ];
      };

    homeManager.hyprland =
      { pkgs, ... }:
      {
        # TODO: maybe move this all to the same config type
        home.packages = with pkgs; [
          alacritty
          power-profiles-daemon
          upower
          upower-notify
        ];
      };
  };
}
