{
  flake.modules.nixos.profiles-plasma-minimal =
    { pkgs, lib, ... }:
    {

      services.displayManager.plasma-login-manager.enable = lib.mkDefault true;
      services.desktopManager.plasma6.enable = true;
      services.displayManager.defaultSession = "plasma";

      environment.plasma6.excludePackages = with pkgs.kdePackages; [
        discover
        kwin-x11
      ];
    };
}
