{
  flake-file.inputs.mwg = {
    url = "git+https://git.toostveen.nl/tom/merge-when-green-fj.git";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  perSystem =
    {
      inputs',
      lib,
      pkgs,
      ...
    }:
    {
      devshells.default = {
        packages = [ inputs'.mwg.packages.default ];
        env = lib.singleton {
          name = "FJ_TOKEN";
          eval = "$(${lib.getExe pkgs.sops} decrypt secrets/forgejo-mwg-token.secret)";
        };
      };
      checks.mwg = inputs'.mwg.checks.default;
    };
}
