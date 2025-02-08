{pkgs, ...}: {
  # is this needed on wayland?
  services.xserver.enable = true;
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;
  services.desktopManager.plasma6.enable = true;
  services.displayManager.defaultSession = "plasma";
  environment.systemPackages = with pkgs; [
    kdePackages.kdeconnect-kde
    kdePackages.plasma-browser-integration
  ];
}
