{ config, ... }:
{
  perSystem =
    { pkgs, lib, ... }:
    {
      files.files = [
        {
          path_ = ".github/workflows/nix-flake-update.yml";
          drv = pkgs.writers.writeYAML "nix-flake-update.yml" {
            on = {
              workflow_dispatch = { };
              schedule = [ { cron = "0 0 * * 0"; } ];
            };

            jobs.nix-flake-update = {
              permissions =
                lib.pipe
                  [ "contents" "id-token" "issues" "pull-requests" ]
                  [
                    (lib.map (v: lib.nameValuePair v "write"))
                    lib.listToAttrs
                  ];

              runs-on = "ubuntu-latest";

              steps = config.flake.actions-setup ++ [
                {
                  uses = "DeterminateSystems/update-flake-lock@v27";
                  "with".pr-title = "chore: nix flake update";
                }
              ];
            };
          };
        }
      ];
    };
}
