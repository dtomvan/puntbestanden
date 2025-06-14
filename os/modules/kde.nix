{
  pkgs,
  lib,
  ...
}:
{
  services.displayManager.sddm.enable = lib.mkDefault true;
  services.displayManager.sddm.wayland.enable = lib.mkDefault true;

  services.desktopManager.plasma6.enable = true;
  services.displayManager.defaultSession = "plasma";
  environment.systemPackages = with pkgs.kdePackages; [
    kdeconnect-kde
    krfb # VNC share/server
    krdc # remote desktop client, should get negotiated by kdeconnect
    plasma-browser-integration

    filelight
    pkgs.haruna
  ];
}
