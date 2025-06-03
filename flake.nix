rec {
  description = "Home Manager configuration of tomvd";

  # HACK: I would do `nixConfig = import ./nix-config.nix` here, but that IS
  # NOT POSSIBLE >:'(

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    flake-parts.url = "github:hercules-ci/flake-parts";

    nixinate.url = "github:matthewcroughan/nixinate";
    nixinate.inputs.nixpkgs.follows = "nixpkgs";

    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko/latest";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops.url = "github:Mic92/sops-nix";
    sops.inputs.nixpkgs.follows = "nixpkgs";

    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    localsend-rs = {
      # private
      url = "github:dtomvan/localsend-rust-impl";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    srvos = {
      url = "github:nix-community/srvos";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix4vscode = {
      url = "github:nix-community/nix4vscode";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lazy-apps = {
      url = "sourcehut:~rycee/lazy-apps";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      self,
      flake-parts,
      home-manager,
      nixpkgs,
      nix-darwin,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } (
      top@{
        config,
        withSystem,
        moduleWithSystem,
        ...
      }:
      {
        imports = [
          ./os/flake-module.nix
        ];

        flake =
          with nixpkgs.lib;
          let
            mkPkgs = system: import ./lib/make-packages.nix { inherit system nixpkgs inputs; };

            getHosts = type: filterAttrs (_k: v: hasInfix type v.system) (import ./hosts.nix);

            makeDarwin =
              _key: host:
              nameValuePair host.hostName (
                nix-darwin.lib.darwinSystem {
                  specialArgs = {
                    inherit host nixConfig inputs;
                  };
                  modules = [ ./darwin/${host.hostName}.nix ];
                }
              );

            makeHome =
              _key: host:
              nixpkgs.lib.nameValuePair "tomvd@${host.hostName}" (
                home-manager.lib.homeManagerConfiguration {
                  pkgs = mkPkgs host.system;

                  modules = import home/modules.nix { inherit host inputs; };

                  extraSpecialArgs = {
                    inherit host;
                  };
                }
              );
          in
          {
            darwinConfigurations = mapAttrs' makeDarwin (getHosts "darwin");

            homeConfigurations = mapAttrs' makeHome (import ./hosts.nix);
          };

        systems = [
          "x86_64-linux"
          "aarch64-linux"
          "aarch64-darwin"
          "x86_64-darwin"
        ];

        perSystem =
          {
            config,
            system,
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
                        -cdrom ${config.packages.iso}/iso/*.iso \
                        -hda "$disk"
                    '';
                  }
                );
              };
            } // (inputs.nixinate.nixinate.${system} self).nixinate;

            formatter = pkgs.nixfmt-tree;

            devShells = { };

            packages = {
              # treefmt for nixpkgs contributors
              nixtreefmt =
                let
                  inherit (import "${nixpkgs}/ci" { inherit nixpkgs system; }) fmt;
                in
                pkgs.symlinkJoin {
                  name = "nixtreefmt";
                  paths = [ fmt.pkg ];
                  postBuild = ''
                    mv $out/bin/{,nix}treefmt
                  '';
                };
            };
          };
      }
    );
}
# vim:sw=2 ts=2 sts=2
