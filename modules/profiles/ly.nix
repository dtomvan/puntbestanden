{ lib, ... }:
{
  flake.modules.nixos.profiles-ly = {
    services.displayManager = {
      ly.enable = true;
      sddm.enable = lib.mkForce false;
      sddm.wayland.enable = lib.mkForce false;
      gdm.enable = lib.mkForce false;
    };
  };
}
