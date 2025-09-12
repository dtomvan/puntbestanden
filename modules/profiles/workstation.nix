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

      environment.systemPackages = with pkgs; [
        emacs-pgtk
        forge-sparks
        keepassxc
        libreoffice-qt6-fresh
        pdfarranger
        pika-backup
        telegram-desktop
        thunderbird
      ];
    };
}
