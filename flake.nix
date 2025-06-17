{
  description = "Home Manager configuration of tomvd";

  # HACK: I would do `nixConfig = import ./nix-config.nix` here, but that IS
  # NOT POSSIBLE >:'(

  # NB: if you change something here, for it to work globally on NixOS, also
  # change it in `nix-config.nix`
  nixConfig = {
    extra-substituters = [
      "https://nix-community.cachix.org"
      "https://cache.garnix.io"
    ];

    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
    ];
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    vs2nix = {
      url = "github:dtomvan/vs2nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

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

    # uncomment for testing
    # nur-packages = {
    #   url = "github:dtomvan/nur-packages/dtomvan/push-ssqqtnvrqmll";
    # inputs.nixpkgs.follows = "nixpkgs";
    # };
  };

  outputs =
    inputs@{
      self,
      flake-parts,
      nixpkgs,
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
          parts/autounattend.nix
          parts/darwin.nix
          parts/home.nix
          parts/os.nix
        ];

        flake = { };

        systems = [
          "x86_64-linux"
          "aarch64-linux"
          "aarch64-darwin"
          "x86_64-darwin"
        ];

        perSystem =
          {
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
