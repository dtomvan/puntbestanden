{
  pkgs,
  lib,
  ...
}:
{
<<<<<<< Updated upstream
  services.displayManager.sddm.enable = lib.mkDefault true;
  services.displayManager.sddm.wayland.enable = lib.mkDefault true;
||||||| Stash base
  services.xserver.enable = true;
  services.xserver.displayManager.lightdm = {
    enable = lib.mkDefault true;
    greeter = lib.mkIf config.services.xserver.displayManager.lightdm.enable {
      name = "lightdm-kde-greeter";
      package = pkgs.lightdm-kde-greeter.xgreeters;
    };
  };
  # services.displayManager.sddm.enable = lib.mkDefault true;
  # services.displayManager.sddm.wayland.enable = lib.mkDefault true;
=======
  services.xserver.enable = true;
  services.xserver.displayManager.lightdm = {
    enable = lib.mkDefault true;
    greeter = {
      name = "lightdm-kde-greeter";
      package = pkgs.lightdm-kde-greeter.xgreeters;
    };
  };

  # services.displayManager.sddm.enable = lib.mkDefault true;
  # services.displayManager.sddm.wayland.enable = lib.mkDefault true;
>>>>>>> Stashed changes

  services.desktopManager.plasma6.enable = true;
  services.displayManager.defaultSession = "plasma";
  environment.systemPackages = with pkgs.kdePackages; [
    kdeconnect-kde
    plasma-browser-integration

    filelight
    pkgs.haruna
  ];
}
