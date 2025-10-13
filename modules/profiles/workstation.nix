{ self, ... }:
{
  flake.modules.nixos.profiles-workstation =
    { pkgs, ... }:
    {
      imports = with self.modules.nixos; [
        profiles-base
        profiles-plasma

        networking-tailscale
        services-copyparty
        services-keybase
        utilities
        virt-distrobox
        virt-docker
      ];

      modules.utilities.enableLazyApps = true;

      # assumes nix-flatpak is available
      services.flatpak.packages = [
        "com.obsproject.Studio"
        "org.gnome.World.PikaBackup"
        "dev.overlayed.Overlayed"
      ];

      environment.systemPackages = with pkgs; [
        discord
        forge-sparks
        keepassxc
        libreoffice-qt6-fresh
        obsidian
        pdfarranger
        pika-backup
        python3
        signal-desktop
        telegram-desktop
        thunderbird
      ];
    };
}
