{ self, ... }:
{
  flake.modules.nixos.profiles-workstation =
    { pkgs, ... }:
    {
      imports = with self.modules.nixos; [
        profiles-base
        profiles-plasma

        services-printing
        services-sane

        networking-tailscale
        services-copyparty
        services-keybase
        utilities
        virt-podman
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
        nixpkgs-reviewFull
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
