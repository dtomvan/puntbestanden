# WARNING: plasma theming might break, so don't use with profiles-plasma, I guess
{ lib, ... }:
{
  flake.modules.nixos.profiles-dank = {
    programs.niri.enable = true;

    services.displayManager = {
      dms-greeter = {
        enable = true;
        compositor.name = "niri";
      };
      sddm.enable = lib.mkForce false;
      sddm.wayland.enable = lib.mkForce false;
      gdm.enable = lib.mkForce false;
    };

    programs.dms-shell = {
      enable = true;
      systemd.enable = false;
    };

    # so dms can write its configs for qt apps
    # qt = {
    #   enable = true;
    #   platformTheme = "qt5ct"; # also does qt6ct
    #   style = lib.mkForce null; # so qt5ct can be overridden by dms
    # };
  };

  flake.modules.homeManager.profiles-dank =
    { pkgs, lib, ... }:
    {
      # let DMS manage GTK themes
      gtk.enable = lib.mkForce false;
      modules.terminals.foot.enable = lib.mkDefault true;
      home.packages = with pkgs; [
        wl-clipboard
        brightnessctl
        pipewire
        rofi
      ];
    };

  flake.modules.nixos.feather.services.displayManager.dms-greeter.enable = lib.mkForce false;
}
