{ inputs, ... }:
{
  # HACK: the nix-index database may not exactly correspond the nixpkgs I pull
  # in, so keep that in mind
  flake-inputs.nix-index-database = {
    url = "github:nix-community/nix-index-database";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake.modules.nixos.programs-comma =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    {
      imports = [ inputs.nix-index-database.nixosModules.nix-index ];

      programs.command-not-found.enable = false;

      environment.systemPackages =
        (import inputs.nix-index-database { inherit pkgs; }).comma-with-db.override {
          comma = pkgs.comma.override { nix = config.nix.package; };
        }
        |> lib.singleton;

      environment.variables.COMMA_PICKER = lib.getExe pkgs.skim;
    };
}
