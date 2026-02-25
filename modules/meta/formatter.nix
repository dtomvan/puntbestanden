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
          # keep-sorted start
          deadnix.enable = true;
          keep-sorted.enable = true;
          nixfmt.enable = true;
          shfmt.enable = true;
          statix.enable = true;
          # keep-sorted end
        };
      };

      devshells.default.packages = with pkgs; [
        # keep-sorted start
        deadnix
        keep-sorted
        nixfmt-tree
        shfmt
        statix
        # keep-sorted end
      ];
    };
}
