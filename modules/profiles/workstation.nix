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
        keepassxc
        libreoffice-qt6-fresh
      ];
    };
}
