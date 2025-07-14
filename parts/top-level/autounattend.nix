{
  self,
  config,
  inputs,
  ...
}:
let
  inherit (inputs.nixpkgs.lib)
    nixosSystem
    ;

  system = "x86_64-linux";
in
{
  flake.nixosConfigurations = {
    autounattend = nixosSystem {
      modules = [
        config.flake.modules.nixos.autounattend
      ];
    };

    installer = nixosSystem {
      modules = [
        inputs.sops.nixosModules.default
        config.flake.modules.nixos.autounattend-installer
      ];
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
                  -hda "$disk" \
                  -nic none
              '';
            }
          );
        };
      };
    };
}
