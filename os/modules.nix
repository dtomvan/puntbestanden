{
  inputs,
  host,
}: let
  lib = inputs.nixpkgs.lib;
in
  [
    inputs.disko.nixosModules.disko
    inputs.sops.nixosModules.sops
    ./common.nix
    ./${host.hostName}.nix
    ./hardware/${host.hostName}.nix
    ./modules/boot/systemd-boot.nix

    ./modules/users/tomvd.nix
    ./modules/users/root.nix
  ]
  ++ lib.optionals host.os.isGraphical [
    ./modules/boot/plymouth.nix

    ./modules/services/printing.nix
    ./modules/services/sane.nix
    ./modules/services/flatpak.nix

    ./hardware/sound.nix

    ./modules/fonts.nix
  ]
  ++ lib.optional host.os.wantsKde ./modules/kde.nix
