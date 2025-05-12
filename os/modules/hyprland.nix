{ pkgs, lib, config, ... }:
{
  # hyprland doesn't set breeze by default, but we do use kde packages. To make
  # them not look like they are the QT apps from your grandma, we specifically
  # specify qt settings here 

  qt = {
    enable = true;
    platformTheme = "qt5ct"; # also does qt6ct
    style = "breeze";
  };

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      kdePackages.xdg-desktop-portal-kde
    ];
    config.common.default = "kde";
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

  # why do I need to set this???!?!?
  services.upower.enable = true;

  # KDE has its own support, and Hyprland of course doesn't
  services.blueman.enable = lib.mkDefault config.hardware.bluetooth.enable;

  programs.hyprlock.enable = true;
  services.hypridle.enable = true;

  # sensible defaults for when the config was manually written, HM could do
  # this also but whatever
  environment.systemPackages = with pkgs; [
    # Some KDE apps which get added to plasma automatically, but which I also want on Hyprland
    kdePackages.okular
    kdePackages.ark
    kdePackages.kate
    haruna


    kdePackages.breeze-icons
    kdePackages.breeze-gtk
  
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
