{
  flake-file = {
    description = "Home Manager configuration of tomvd";

    inputs = {
      nixpkgs.url = "https://channels.nixos.org/nixos-unstable/nixexprs.tar.xz";

      nixpkgs-unfree = {
        url = "github:numtide/nixpkgs-unfree";
        inputs.nixpkgs.follows = "nixpkgs";
      };

      disko = {
        url = "github:nix-community/disko/latest";
        inputs.nixpkgs.follows = "nixpkgs";
      };

      lazy-apps = {
        url = "sourcehut:~rycee/lazy-apps";
        inputs.nixpkgs.follows = "nixpkgs";
      };
    };
  };
}
