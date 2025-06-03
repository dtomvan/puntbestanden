rec {
  description = "Home Manager configuration of tomvd";

  # HACK: I would do `nixConfig = import ./nix-config.nix` here, but that IS
  # NOT POSSIBLE >:'(

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    flake-parts.url = "github:hercules-ci/flake-parts";

    nixinate = {
      url = "github:matthewcroughan/nixinate";
      inputs.nixpkgs.follows = "nixpkgs";
    };

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

    sops = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

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
          ./darwin/flake-module.nix
          ./os/flake-module.nix
          ./os/autounattend/flake-module.nix
        ];

        flake =
          with nixpkgs.lib;
          let
            mkPkgs = system: import ./lib/make-packages.nix { inherit system nixpkgs inputs; };

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
            apps = (inputs.nixinate.nixinate.${system} self).nixinate;

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
