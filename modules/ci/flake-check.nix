# This being a nix file instead of a yml file is basically a running joke at
# this point
{ self, ... }:
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
              steps = self.actions-setup ++ [
                { run = "nix flake lock"; }
                { run = "nix flake check -L"; }
              ];
            };
          };
        }
      ];
    };
}
