{ lib, ... }:
{
  flake.modules.nixos.profiles-ly = {
    services.displayManager = {
      ly.enable = true;
      plasma-login-manager.enable = lib.mkForce false;
      gdm.enable = lib.mkForce false;
    };
  };
}
