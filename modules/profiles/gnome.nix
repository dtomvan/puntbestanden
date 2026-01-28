{
  flake.modules.nixos.profiles-gnome =
    { pkgs, lib, ... }:
    {
      services.xserver = {
        enable = true;
        desktopManager.gnome.enable = true;
        displayManager.gdm.enable = lib.mkDefault true;
      };

      services.udev.packages = with pkgs; [ gnome-settings-daemon ];

      # Bloat
      environment.gnome.excludePackages = with pkgs; [
        atomix
        cheese
        epiphany
        geary
        gnome-characters
        gnome-console
        gnome-music
        hitori
        iagno
        tali
      ];
    };
}
