{ inputs, ... }:
{
  imports = [ inputs.flake-file.flakeModules.default ];
  flake-file = {
    description = "Home Manager configuration of tomvd";

    inputs = {
      nixpkgs.url = "https://channels.nixos.org/nixos-unstable/nixexprs.tar.xz";

      nixpkgs-unfree = {
        url = "github:numtide/nixpkgs-unfree";
        inputs.nixpkgs.follows = "nixpkgs";
      };

      vs2nix = {
        url = "github:dtomvan/vs2nix";
        inputs.nixpkgs.follows = "nixpkgs";
      };

      flake-parts.url = "github:hercules-ci/flake-parts";
      import-tree.url = "github:vic/import-tree";
      flake-file.url = "github:vic/flake-file";

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

      flake-fmt = {
        url = "github:Mic92/flake-fmt";
        inputs.nixpkgs.follows = "nixpkgs";
      };

      plasma-manager = {
        url = "github:nix-community/plasma-manager";
        inputs.nixpkgs.follows = "nixpkgs";
        inputs.home-manager.follows = "home-manager";
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

      treefmt-nix = {
        url = "github:numtide/treefmt-nix";
        inputs.nixpkgs.follows = "nixpkgs";
      };

      nix-index-database = {
        url = "github:nix-community/nix-index-database";
        inputs.nixpkgs.follows = "nixpkgs";
      };

      # uncomment for testing
      # nur-packages = {
      #   url = "github:dtomvan/nur-packages/dtomvan/push-ssqqtnvrqmll";
      # inputs.nixpkgs.follows = "nixpkgs";
      # };
    };
  };
}
