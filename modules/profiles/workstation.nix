{ config, ... }:
{
  flake.modules.nixos.profiles-workstation =
    { pkgs, ... }:
    {
      imports = with config.flake.modules.nixos; [
        profiles-base
        profiles-plasma

        networking-tailscale
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
