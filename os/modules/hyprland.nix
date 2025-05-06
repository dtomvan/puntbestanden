{ pkgs, ... }:
{
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

  environment.sessionVariables.NIXOS_OZONE_WL = "1";
}
