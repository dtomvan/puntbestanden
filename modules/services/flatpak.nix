{
  flake.modules.nixos.services-flatpak = {
    services.flatpak.enable = true;
    security.polkit.enable = true;
  };
}
