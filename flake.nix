rec {
  description = "Home Manager configuration of tomvd";

  nixConfig = {
    extra-substituters = [
      "https://nix-community.cachix.org"
    ];

    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    zozin.url = "github:dtomvan/zozin.nix";

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

    # TODO: not yet actually on the NUR, refactor when it is
    nur-packages = {
      url = "github:dtomvan/nur-packages";
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
        imports = [ ];

        flake =
          let
            mkPkgs =
              system:
              import nixpkgs {
                inherit system;
                config.allowUnfree = true;
                overlays = [
                  inputs.nur.overlays.default
                  inputs.nix4vscode.overlays.forVscode
                  inputs.lazy-apps.overlays.default
                  # broken
                  # (_final: _prev: { nix4vscode.forOpenVsx = inputs.nix4vscode.lib.${system}.forOpenVsx; })
                  (_final: _prev: inputs.zozin.packages.${system})
                  (_final: _prev: self.packages.${system})
                  (_final: _prev: inputs.nur-packages.packages.${system})
                ];
              };
          in
          with nixpkgs.lib;
          {
            nixosConfigurations = mapAttrs' (
              _key: host:
              nameValuePair host.hostName (nixosSystem {
                specialArgs = {
                  inherit host nixConfig inputs;
                };
                modules = import os/modules.nix { inherit host inputs; } ++ host.os.extraModules; # nixpkgs is dumb
                pkgs = mkPkgs host.system;
              })
            ) (filterAttrs (_k: v: hasInfix "linux" v.system) (import ./hosts.nix));

            darwinConfigurations = mapAttrs' (
              _key: host:
              nameValuePair host.hostName (
                nix-darwin.lib.darwinSystem {
                  specialArgs = {
                    inherit host nixConfig inputs;
                  };
                  modules = [ ./darwin/${host.hostName}.nix ];
                }
              )
            ) (filterAttrs (_k: v: hasInfix "darwin" v.system) (import ./hosts.nix));

            homeConfigurations = nixpkgs.lib.mapAttrs' (
              _key: host:
              nixpkgs.lib.nameValuePair "tomvd@${host.hostName}" (
                home-manager.lib.homeManagerConfiguration {
                  pkgs = mkPkgs host.system;

                  modules = import home/modules.nix { inherit host inputs; };

                  extraSpecialArgs = {
                    inherit host;
                  };
                }
              )
            ) (import ./hosts.nix);
          };

        systems = [
          "x86_64-linux"
          "aarch64-linux"
          "aarch64-darwin"
          "x86_64-darwin"
        ];

        perSystem =
          { system, pkgs, ... }:
          {
            apps = { } // (inputs.nixinate.nixinate.${system} self).nixinate;

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
