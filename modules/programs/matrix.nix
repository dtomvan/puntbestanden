{ lib, ... }:
{
  flake.modules.nixos.profiles-workstation.services.flatpak.packages = lib.singleton "in.cinny.Cinny";
}
