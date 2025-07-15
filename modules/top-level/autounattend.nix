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

  isoTarget = "iso";
  demoTarget = "install-demo";
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
    ${isoTarget} = self.nixosConfigurations.installer.config.system.build.isoImage;
  };

  perSystem =
    {
      pkgs,
      ...
    }:
    {
      apps = {
        ${demoTarget} = {
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

  text.readme.parts.autounattend =
    # markdown
    ''
      # Autounattend
      This repository includes an "autounattend" installer ISO, which:
      - Installs a nested, pre-defined NixOS configuration
      - Without any user interaction required apart from booting it
      - Does not require internet

      To create the iso, run `nix build .#${isoTarget}`.

      To run an install demo in QEMU, run `nix run .#${demoTarget}`.

      If you do not have access to the secrets in this repo you'll need to
      comment out the `networking-wifi-passwords` import in order to build it.
    '';
}
