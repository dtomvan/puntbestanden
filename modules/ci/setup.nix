{ lib, ... }:
{
  options.flake.actions-setup = lib.mkOption {
    description = "The common set of actions that need to be run before Nix-related stuff can happen in CI";
    default = [ ];
    type = with lib.types; listOf attrs;
  };

  config.flake.actions-setup = [
    {
      name = "Check that access token works";
      env.GH_TOKEN = "\${{ secrets.NIX_GITHUB_TOKEN }}";
      run = "gh api repos/dtomvan/localsend-rust-impl >/dev/null";
    }
    { uses = "actions/checkout@v4"; }
    {
      uses = "cachix/install-nix-action@v31";
      "with".github_access_token = "\${{ secrets.NIX_GITHUB_TOKEN }}";
    }
  ];
}
