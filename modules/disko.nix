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
          gawk,
          coreutils,
        }:
        writeShellApplication {
          name = "get-disk-id";
          runtimeInputs = [
            util-linux
            jq
            gawk
            coreutils
          ];
          text = ''
            doit () {
              blocks="$(lsblk -o MOUNTPOINTS,ID -J)"
              for mount in /mnt / "$@"; do
                printf "mountpoint %s: " "$mount"
                # ensure consistent output: jq never outputs a newline, because
                # halt_error(0) prints the string without a newline (to stderr
                # but we redirect), with exit code 0, if the input made it thru
                # the select, and bash always prints a newline afterwards. That
                # way we don't have to trim jq's output
                jq --arg mount "$mount" \
                  -r '.blockdevices | map(select(.mountpoints | index($mount)) | "/dev/disk/by-id/\(.id)" | halt_error(0))[]' \
                  <<< "$blocks" \
                  2>&1
                echo
              done
            }
            if [ "''${1:-}" = --raw ]; then
              shift
              doit "$@" | awk '(NF > 2) { print $NF }' | head -n1
            else
              doit "$@"
            fi
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
