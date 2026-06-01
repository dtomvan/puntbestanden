{ inputs, ... }:
{
  flake-inputs.disko = {
    url = "github:nix-community/disko/latest";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake.modules.nixos.disko =
    { host, ... }:
    {
      imports = [
        inputs.disko.nixosModules.disko
        (import ./community/autounattend/_disko.nix {
          device = host.mainDisk or throw "disko imported but host.mainDisk not set";
        })
      ];
    };

  perSystem =
    { pkgs, ... }:
    {
      devshells.default.packages = [ pkgs.disko ];

      packages.get-disk-id = pkgs.callPackage (
        {
          writeShellApplication,
          util-linux,
          jq,
        }:
        writeShellApplication {
          name = "get-disk-id";
          runtimeInputs = [
            util-linux
            jq
          ];
          text = ''
            blocks="$(lsblk -o MOUNTPOINTS,ID -J)"
            for mount in / /mnt "$@"; do
              printf "mountpoint %s: " "$mount"
              jq -r '.blockdevices | map(select(.mountpoints | index("'"$mount"'")) | "/dev/disk/by-id/\(.id)")[]' <<< "$blocks"
            done
          '';
        }
      ) { };
    };

  text.readme.parts.disko_install = ''

    ## How to install
    A single command:
    ```ShellSession
    $ nix develop -c sudo disko-install -m format --flake .#<HOSTNAME> --disk main /dev/nvme0n1
    ```
  '';
}
