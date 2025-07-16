{ inputs, ... }:
{
  flake-file.inputs = {
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  imports = [ inputs.treefmt-nix.flakeModule ];
  perSystem =
    { pkgs, ... }:
    {
      treefmt = {
        programs = {
          deadnix.enable = true;
          nixfmt.enable = true;
          shfmt.enable = true;
          statix.enable = true;
        };
      };

      devshells.default.packages = with pkgs; [
        deadnix
        nixfmt-tree
        shfmt
        statix
      ];
    };
}
