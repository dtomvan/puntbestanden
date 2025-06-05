{ self, inputs, ... }:
with inputs.nixpkgs.lib;
let
  nixConfig = import ../../nix-config.nix;
  mkPkgs = system: import ../../lib/make-packages.nix { inherit self system inputs; };
  system = "x86_64-linux";
in
{
  flake.nixosConfigurations = rec {
    autounattend = nixosSystem {
      pkgs = mkPkgs system;
      modules = [
        ./configuration.nix
        { nixpkgs.hostPlatform = system; }
      ];
      specialArgs = {
        inherit nixConfig inputs;
        host = {
          hostName = "nixos";
          inherit system;
          hardware.cpuVendor = "intel";
          os = {
            isGraphical = false;
            wantsKde = false;
          };
        };
      };
    };

    installer = nixosSystem {
      pkgs = mkPkgs system;
      modules = [
        inputs.sops.nixosModules.default
        ./installer.nix
      ];
      specialArgs = {
        inherit nixConfig inputs;
        evaluatedSystem = autounattend;
      };
    };
  };

  flake.packages.${system} = {
    iso = self.nixosConfigurations.installer.config.system.build.isoImage;
  };

  perSystem =
    {
      pkgs,
      ...
    }:
    {
      apps = {
        install-demo = {
          type = "app";
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
                  -cdrom ${self.packages.${system}.iso}/iso/*.iso \
                  -hda "$disk"
              '';
            }
          );
        };
      };
    };
}
