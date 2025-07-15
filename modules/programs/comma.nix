{ inputs, ... }:
{
  flake-file.inputs = {
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  flake.modules.nixos.programs-comma =
    { pkgs, lib, ... }:
    {
      imports = [ inputs.nix-index-database.nixosModules.nix-index ];

      programs.command-not-found.enable = false;
      programs.nix-index.enable = true;
      programs.nix-index-database.comma.enable = true;

      environment.variables.COMMA_PICKER = lib.getExe pkgs.skim;
    };
}
