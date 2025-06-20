{
  inputs,
  host,
}:
let
  lib = inputs.nixpkgs.lib;
in
[
  inputs.disko.nixosModules.disko
  inputs.sops.nixosModules.sops
  inputs.srvos.nixosModules.mixins-terminfo
  inputs.vs2nix.nixosModules.default
  # inputs.zozin.nixosModules.olive_c
  # inputs.zozin.nixosModules.koil

  ./common.nix
  ./hosts/${host.hostName}.nix
  ./hardware/${host.hostName}.nix
  ./modules/boot/systemd-boot.nix

  # as long as you have /root/.ssh/remotebuild this will work, I hope it
  # builds on systems which don't at least
  ./modules/distributed-builds.nix

  ./modules/networking/wifi-passwords.nix
  ./modules/services/ssh.nix

  ./modules/users/tomvd.nix
  ./modules/users/root.nix

  ./modules/localsend-rs.nix
]
++ lib.optional host.remoteBuild.enable ./modules/users/remote-build.nix
++ lib.optionals host.os.isGraphical [
  ./modules/boot/plymouth.nix

  ./modules/services/printing.nix
  ./modules/services/sane.nix
  ./modules/services/flatpak.nix

  ./hardware/sound.nix

  ./modules/fonts.nix
]
++ lib.optional ((host.hardware.gpuVendor or "unknown") == "nvidia") ./hardware/nvidia.nix
++ lib.optional host.os.wantsKde ./modules/kde.nix
