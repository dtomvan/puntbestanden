{ config, ... }:
{
  flake.modules.nixos.profiles-graphical =
    { pkgs, ... }:
    {
      imports = with config.flake.modules.nixos; [
        boot-plymouth

        services-bazaar
        services-flatpak
        services-printing
        services-sane

        hardware-sound

        fonts
      ];

      environment.systemPackages = with pkgs; [
        wl-clipboard
        pavucontrol
        alsa-utils
      ];
    };
}
