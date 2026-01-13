{ self, ... }:
{
  perSystem =
    { pkgs, ... }:
    {
      # self-install the live NixOS environment to a different disk, as to
      # kind-of "clone" the current setup somewhere else.
      #
      # Yes, this is in many ways similar to the script in
      # modules/community/autounattend/installer.nix...
      packages.nixos-self-install = pkgs.writeShellApplication {
        name = "nixos-self-install";
        runtimeInputs = with pkgs; [
          disko
          gum
          jq
          nixos-install
          util-linux
        ];
        text = ''
          declare -a blk
          mapfile -t blk < <(lsblk -J | jq -r '.blockdevices | map("/dev/\(.name)")[]')

          target="$(gum choose --header="Choose a disk to install to:" "''${blk[@]}")"

          gum confirm \
            --default=no \
            "Are you sure you want to self-install to $target AND OVERWRITE ALL OF THE DISKS CONTENTS?" \
            || exit 1

          mkdir -p /etc/nixos
          cp -r ${self}/* /etc/nixos
          chmod -R 755 /etc/nixos

          disko \
            -m destroy,format,mount \
            --argstr device "$target" \
            ${../community/autounattend/_disko.nix}

          nixos-generate-config \
            --show-hardware-config \
            --root /mnt \
            > /etc/nixos/modules/hub/_hardware-configuration.nix

          # do this thing "as offline as possible"
          nix copy --all --to /mnt --no-check-sigs

          mkdir -p /mnt/etc
          cp -r /etc/nixos /mnt/etc
          chown -R me:users /mnt/etc/nixos
          chmod -R 755 /mnt/etc/nixos

          nixos-install \
            --flake /mnt/etc/nixos#hub \
            --no-root-passwd \
            --no-channel-copy \
            --option accept-flake-config true
        '';
      };
    };

  flake.modules.nixos.hub =
    { pkgs, lib, ... }:
    {
      environment.sessionVariables.NIX_PATH = lib.mkForce "nixpkgs=${pkgs.path}";

      nix = {
        enable = lib.mkForce true; # needed for generating a disko script, and probably also to install nixos
        settings.experimental-features = [
          "nix-command"
          "flakes"
        ];
      };

      system.switch.enable = lib.mkForce true; # needed to install to bootloader anyways

      environment.systemPackages = [
        self.packages.${pkgs.stdenv.hostPlatform.system}.nixos-self-install
      ];
    };
}
