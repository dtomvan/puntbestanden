{pkgs ? import <nixpkgs> {}, ...}: {
  default = pkgs.mkShell {
    NIX_CONFIG = "extra-experimental-features = nix-command flakes";
    nativeBuildInputs = with pkgs; [
      nix
      home-manager
      git
      tmux
    ];
    shellHook = ''
         echo "To install, run something along the lines of:"
         echo "---"
      echo "$ tmux"
         echo "# nixos-generate-config --show-hardware-config --no-filesystems --root /mnt > hardware/tom-pc.nix"
      echo "WARNING: CHECK WETHER the disko configs under /hardware are any good"
         echo "# nix run 'github:nix-community/disko/latest#disko-install' -- --write-efi-boot-entries --flake .#tom-pc --disk main /dev/nvme0n1"
      echo "$ pushd .."
         echo "$ cp -r puntbestanden /mnt/home/tomvd/puntbestanden"
         echo "$ reboot"
    '';
  };
}
