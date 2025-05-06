{ pkgs, ... }:
{
  # hyprland doesn't set breeze by default, but we do use kde packages. To make
  # them not look like they are the QT apps from your grandma, we specifically
  # specify qt settings here 

  qt = {
    enable = true;
    platformTheme = "qt5ct"; # also does qt6ct
    style = "breeze";
  };

  programs.regreet = {
    enable = true;
    font = {
      name = "Inter";
      package = pkgs.inter;
    };
    settings = {
      # todo: dedupe
      background.path = pkgs.nixos-artwork.wallpapers.nineish-catppuccin-mocha.passthru.kdeFilePath;
      GTK.application_prefer_dark_theme = true;
    };
  };

  programs.hyprland = {
    enable = true;
    withUWSM = true;
  };

  programs.hyprlock.enable = true;
  services.hypridle.enable = true;

  # sensible defaults for when the config was manually written, HM could do
  # this also but whatever
  environment.systemPackages = with pkgs; [
    wireplumber
    brightnessctl
    playerctl
    fnott
    kdePackages.xwaylandvideobridge
    kdePackages.dolphin
    clipse
    eww
    socat
    grimblast
  ];

  services.playerctld.enable = true;

  environment.sessionVariables.NIXOS_OZONE_WL = "1";
}
