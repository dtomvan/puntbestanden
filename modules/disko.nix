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
      ];

      config = {
        assertions = [
          {
            assertion = host.mainDisk != null;
            message = "host.mainDisk must be set when disko is imported";
          }
        ];

        disko.devices.disk.main = {
          device = host.mainDisk;

          type = "disk";

          content = {
            type = "gpt";
            partitions = {
              BOOT = {
                size = "1G";
                type = "EF00";
                content = {
                  type = "filesystem";
                  format = "vfat";
                  mountpoint = "/boot";
                  mountOptions = [
                    "fmask=0022"
                    "dmask=0022"
                  ];
                };
              };
              swap = {
                size = "8G"; # TODO: adjust per-machine
                content = {
                  type = "swap";
                  discardPolicy = "both";
                  resumeDevice = false;
                };
              };
              NIXOS = {
                size = "100%";
                content = {
                  type = "filesystem";
                  format = "xfs";
                  mountpoint = "/";
                  mountOptions = [
                    "defaults"
                    "noatime" # saves overhead
                  ];
                };
              };
            };
          };
        };
      };
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
