{pkgs ? import <nixpkgs> {}, ...}: {
  default = pkgs.mkShell {
    NIX_CONFIG = "extra-experimental-features = nix-command flakes";
    nativeBuildInputs = with pkgs; [
      nix
      home-manager
      git
    ];
    shellHook = ''
    echo "To install, run something along the lines of:"
    echo "---"
    echo "# cfdisk"
    echo "# mkfs.ext4 -L nixos /dev/sda1"
    echp "# mkfs.fat -F 32 -n boot /dev/sda2"
    echo "# mount /dev/sda1 /mnt"
    echo "# mount /dev/sda2 /mnt/boot"
    echo "# nixos-generate-config --root /mnt"
    echo "$ cp /mnt/etc/nixos/hardware-config.nix hardware/tom-pc.nix"
    echo "# nixos-rebuild --switch --flake .#tom-pc"
	echo "$ pushd .."
    echo "$ cp -r puntbestanden /mnt/home/tomvd/puntbestanden"
    echo "$ reboot"
    '';
  };
}
