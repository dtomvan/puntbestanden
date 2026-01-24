{
  flake.modules.nixos.profiles-plasma-minimal =
    { pkgs, lib, ... }:
    {

      services.displayManager.sddm.enable = lib.mkDefault true;
      services.displayManager.sddm.wayland.enable = lib.mkDefault true;

      services.desktopManager.plasma6.enable = true;
      services.displayManager.defaultSession = "plasma";

      environment.plasma6.excludePackages = with pkgs; [
        kdePackages.discover
        kdePackages.kwin-x11
      ];
    };
}
