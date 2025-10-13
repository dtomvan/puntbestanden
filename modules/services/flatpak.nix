{
  inputs,
  lib,
  ...
}:
{
  flake-file.inputs = {
    nix-flatpak.url = "github:gmodena/nix-flatpak/latest";
  };

  flake.modules.nixos.profiles-graphical = {
    imports = [
      # this module also installs flathub remote by default
      inputs.nix-flatpak.nixosModules.nix-flatpak
    ];

    services.flatpak = {
      enable = true;

      update.auto.enable = lib.mkDefault false;
      uninstallUnmanaged = lib.mkDefault true;

      packages = [
        "com.github.tchx84.Flatseal"
        "com.obsproject.Studio"
        "org.gnome.World.PikaBackup"
        "io.github.kolunmi.Bazaar"
      ];
    };

    security.polkit.enable = true;
  };
}
