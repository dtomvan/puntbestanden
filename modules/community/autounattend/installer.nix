# adapted from https://github.com/tfc/nixos-auto-installer
# mostly to use disko and xfs
{ config, ... }:
let
  inherit (config.autounattend) diskoFile;
  evaluatedSystem = config.flake.nixosConfigurations.autounattend;
in
{
  flake.modules.nixos.autounattend-installer =
    {
      config,
      lib,
      pkgs,
      modulesPath,
      ...
    }:
    {
      imports = [
        "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
        "${modulesPath}/installer/cd-dvd/channel.nix"
      ];

      nixpkgs.config.allowUnfree = true;

      environment.sessionVariables.NIX_PATH = lib.mkForce "nixpkgs=${pkgs.path}";

      # parity with eventual configuration for closure size optimization
      boot.kernelPackages = lib.mkForce pkgs.linuxPackages_6_12_hardened;

      nix.settings.experimental-features = [
        "nix-command"
        "flakes"
      ];

      isoImage = {
        edition = lib.mkForce "autounattend";
        squashfsCompression = "gzip -Xcompression-level 1";
      };

      hardware.enableAllFirmware = true;

      services.getty.helpLine = ''
        ┌──────────────────────────────────────────────────┐
        │                                                  │
        │ ▄▄▄   ▄▄     ██                 ▄▄▄▄      ▄▄▄▄   │
        │ ███   ██     ▀▀                ██▀▀██   ▄█▀▀▀▀█  │
        │ ██▀█  ██   ████     ▀██  ██▀  ██    ██  ██▄      │
        │ ██ ██ ██     ██       ████    ██    ██   ▀████▄  │
        │ ██  █▄██     ██       ▄██▄    ██    ██       ▀██ │
        │ ██   ███  ▄▄▄██▄▄▄   ▄█▀▀█▄    ██▄▄██   █▄▄▄▄▄█▀ │
        │ ▀▀   ▀▀▀  ▀▀▀▀▀▀▀▀  ▀▀▀  ▀▀▀    ▀▀▀▀     ▀▀▀▀▀   │
        │                                                  │
        │                                                  │
        └──────────────────────────────────────────────────┘

        Commencing automatic installation in a few moments...

        Note: if you do not want this, power off the machine right now
      '';

      services.journald.console = "/dev/tty1";

      systemd.services.install = {
        description = "Bootstrap a NixOS installation";
        wantedBy = [ "multi-user.target" ];
        after = [
          "network.target"
          "polkit.service"
          "getty@tty1.service"
        ];
        path = [ "/run/current-system/sw/" ];
        script =
          with pkgs;
          # bash
          ''
            set -euxo pipefail

            echo "Choosing between disks (in that order):"
            echo "  /dev/vda"
            echo "  /dev/nvme0n1"
            echo "  /dev/sda"

            dev=/dev/sda
            [ -b /dev/nvme0n1 ] && dev=/dev/nvme0n1
            [ -b /dev/vda ] && dev=/dev/vda

            n=15
            echo "Installing NixOS on $dev in $n seconds..."

            while [ $n -ne 0 ]; do
              echo "WIPING YOUR MAIN DISK $dev IN $n!!!"
              sleep 1
              n=$((n-1))
            done

            ${disko}/bin/disko \
              --yes-wipe-all-disks \
              --no-deps \
              -m destroy,format,mount \
              --argstr device "$dev" \
              "${diskoFile}"

            mkdir -p /mnt/etc/nixos/
            cp -r ${../..}/* /mnt/etc/nixos/
            chmod -R 755 /mnt/etc/nixos

            ${config.system.build.nixos-install}/bin/nixos-install \
              --system ${evaluatedSystem.config.system.build.toplevel} \
              --no-root-passwd \
              --cores 0

            echo '--------------------------------------------------------------------------------'
            echo '                              Done. Shutting off.                               '
            echo '--------------------------------------------------------------------------------'

            sleep 3
            ${systemd}/bin/systemctl poweroff
          '';
        environment = config.nix.envVars // {
          inherit (config.environment.sessionVariables) NIX_PATH;
          HOME = "/root";
        };
        serviceConfig = {
          Type = "oneshot";
        };
      };

      nixpkgs.hostPlatform = "x86_64-linux";
    };
}
