{ inputs, ... }:
{
  imports = [ inputs.treefmt-nix.flakeModule ];
  perSystem.treefmt = {
    programs = {
      nixfmt.enable = true;
      statix.enable = true;
      deadnix.enable = true;
      shfmt.enable = true;
    };
  };
}
