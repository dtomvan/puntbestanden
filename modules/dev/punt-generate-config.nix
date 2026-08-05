{ lib, ... }:
let
  inherit (lib) singleton;
in
{
  perSystem =
    {
      pkgs,
      self',
      system,
      ...
    }:
    {
      packages.punt-generate-config = pkgs.writeShellApplication {
        name = "punt-generate-config";
        runtimeInputs = builtins.attrValues {
          inherit (pkgs)
            coreutils
            gitMinimal
            gnused
            nixfmt
            envsubst
            ;
          inherit ((pkgs.nixos { }).config.system.build) nixos-generate-config;
          inherit (self'.packages) get-disk-id;
        };
        derivationArgs = {
          preferLocalBuild = true;
          allowSubstitutes = false;
        };
        inheritPath = false;
        runtimeEnv = {
          TEMPLATE =
            builtins.toFile "template.nix"
              # nix
              ''
                { self, ... }:
                {
                  hosts.AAAAAA = {
                    description = "";
                    system = "${system}";
                    users = [ "tomvd" ];
                    mainDisk = "''${diskid}";

                    networking.hostName = "''${hostname}";

                    flatpak = {
                      enable = true;
                      packages = [
                      ];
                    };
                  };

                  flake.modules = {
                    nixos.hosts-feather =
                      { lib, ... }:
                      {
                        imports = builtins.attrValues {
                          inherit (self.modules.nixos)
                            disko
                            profiles-base
                            ;
                        };

                        environment.stub-ld.enable = false;

                        system.stateVersion = "26.11";
                      };

                    homeManager."tomvd@''${hostname}" = {
                      imports = builtins.attrValues {
                        inherit (self.modules.homeManager)
                          profiles-base
                          ;
                      };

                      home.stateVersion = "26.11";
                    };

                    maid."tomvd@''${hostname}" = {
                      imports = builtins.attrValues {
                        inherit (self.modules.maid)
                          ;
                      };
                    };
                  };
                }
              '';
        };
        text = ''
          pushd "$(git rev-parse --show-toplevel)"

          if [ "$#" -lt 1 ]; then
            echo Usage: "$0" HOSTNAME
            exit 1
          fi
          hostname="$1" && shift

          echo generating hardware config...

          diskid="$(get-disk-id --raw)"

          nixos-generate-config --show-hardware-config --no-filesystems |
            sed 's|#.*||' |
            nixfmt - |
            tee "modules/hardware/_generated/$hostname.nix"

          echo done, writing template under hosts/

          export hostname diskid
          envsubst < "''${TEMPLATE:?}" > "modules/hosts/$hostname.nix"
        '';
      };
      devshells.default.packages = singleton self'.packages.punt-generate-config;
    };
}
