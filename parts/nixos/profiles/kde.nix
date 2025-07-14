{ config, ... }:
let
  inherit (config.flake.modules) nixos;
in
{
  flake.modules.nixos.profiles-kde =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    {
      imports = [ nixos.profiles-graphical ];

      services.displayManager.sddm.enable = lib.mkDefault true;
      services.displayManager.sddm.wayland.enable = lib.mkDefault true;

      services.desktopManager.plasma6.enable = true;
      services.displayManager.defaultSession = "plasma";
      environment.systemPackages =
        with pkgs.kdePackages;
        [
          kdeconnect-kde
          krfb # VNC share/server
          krdc # remote desktop client, should get negotiated by kdeconnect
          plasma-browser-integration

          filelight
          pkgs.haruna
        ]
        ++ lib.optionals config.services.tailscale.enable [ pkgs.ktailctl ]
        ++ lib.optionals config.hardware.sane.enable [ pkgs.kdePackages.skanpage ];
    };
}
