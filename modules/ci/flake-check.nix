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
                {
                  name = "Check that access token works";
                  env.GH_TOKEN = "\${{ secrets.LOCALSEND_TOKEN }}";
                  run = "gh api repos/dtomvan/localsend-rust-impl >/dev/null";
                }
                { uses = "actions/checkout@v4"; }
                {
                  uses = "cachix/install-nix-action@v31";
                  "with".github_access_token = "\${{ secrets.LOCALSEND_TOKEN }}";
                }
                { run = "nix flake lock"; }
                { run = "nix flake check -L"; }
              ];
            };
          };
        }
      ];
    };
}
