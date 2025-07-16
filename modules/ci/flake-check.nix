# This being a nix file instead of a yml file is basically a running joke at
# this point
{
  perSystem =
    { pkgs, ... }:
    {
      files.files = [
        {
          path_ = ".github/workflows/nix-flake-check.yml";
          drv = pkgs.writers.writeYAML "nix-flake-check.yml" {
            on = {
              pull_request = { };
              push.branches = [ "main" ];
            };

            jobs.nix-flake-check = {
              runs-on = "ubuntu-latest";
              steps = [
                { uses = "actions/checkout@v4"; }
                { uses = "cachix/install-nix-action@v31"; }
                { run = "nix flake check -L"; }
              ];
            };
          };
        }
      ];
    };
}
