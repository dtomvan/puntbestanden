{
  self,
  lib,
  config,
  inputs,
  flake-parts-lib,
  ...
}:
let
  cfg = config.autounattend;

  inherit (inputs.nixpkgs.lib)
    nixosSystem
    ;

  system = "x86_64-linux";
in
{
  options.autounattend = flake-parts-lib.mkSubmoduleOptions {
    isoTarget = lib.mkOption {
      description = "nix build .#{what} to get your autounattend ISO";
      default = "autounattend-iso";
      type = lib.types.str;
    };

    demoTarget = lib.mkOption {
      description = "nix run .#{what} to run a QEMU demo of your autounattend installer";
      default = "install-demo";
      type = lib.types.str;
    };

    diskoFile = lib.mkOption {
      description = "path to a disko file to automatically partition the disk with during installation. needs to accept the `device` argstr.";
      default = ./_disko.nix;
      type = lib.types.pathInStore;
    };

    configRoot = lib.mkOption {
      description = "path to the root of the config so the installer can copy it to /etc/nixos";
      default = ../../..;
      type = lib.types.pathInStore;
    };
  };

  config = {
    autounattend = lib.mkDefault { };

    flake.nixosConfigurations = {
      autounattend-installer = nixosSystem {
        modules = [
          self.modules.nixos.autounattend-installer
          (self.lib.system system)
        ];
      };
    };

    flake.packages.${system} = {
      ${cfg.isoTarget} = self.nixosConfigurations.autounattend-installer.config.system.build.isoImage;
    };

    perSystem =
      {
        self',
        pkgs,
        ...
      }:
      {
        apps = {
          ${cfg.demoTarget} = {
            type = "app";
            meta.description = "Demo what your autounattend installer would look like in a VM";
            program = pkgs.lib.getExe (
              pkgs.writeShellApplication {
                name = "install-demo";
                text = ''
                  set -euo pipefail
                  disk=root.img
                  if [ ! -f "$disk" ]; then
                    echo "Creating harddisk image root.img"
                    ${pkgs.qemu}/bin/qemu-img create -f qcow2 "$disk" 20G
                  fi
                  ${pkgs.qemu}/bin/qemu-system-x86_64 \
                    -cpu host \
                    -enable-kvm \
                    -m 2G \
                    -bios ${pkgs.OVMF.fd}/FV/OVMF.fd \
                    -cdrom ${self'.packages.${cfg.isoTarget}}/iso/*.iso \
                    -hda "$disk" \
                    -nic none
                '';
              }
            );
          };
        };
      };
  };
}
