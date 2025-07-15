{
  flake.modules = {
    nixos.hyprland =
      { pkgs, ... }:
      {
        # sensible defaults for when the config was manually written, HM could
        # do this also but whatever
        environment.systemPackages = with pkgs; [
          # Some KDE apps which get added to plasma automatically, but which I also want on Hyprland
          kdePackages.ark
          kdePackages.dolphin
          kdePackages.kate
          kdePackages.okular
          haruna

          kdePackages.breeze-icons
          kdePackages.breeze-gtk

          wireplumber
          brightnessctl
          playerctl
          fnott
          kdePackages.xwaylandvideobridge
          clipse
          eww
          socat
          grimblast
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
