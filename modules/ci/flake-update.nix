{ self, ... }:
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

            jobs.nix-flake-update =
              let
                branch = "update_flake_lock_action";
                msg = "chore: nix flake update";
              in
              {
                permissions =
                  lib.pipe
                    [ "contents" "id-token" "issues" "pull-requests" ]
                    [
                      (lib.map (v: lib.nameValuePair v "write"))
                      lib.listToAttrs
                    ];

                runs-on = "ubuntu-latest";

                steps = self.actions-setup ++ [
                  {
                    uses = "DeterminateSystems/update-flake-lock@v27";
                    "with" = {
                      inherit branch;
                      commit-msg = msg;
                      pr-title = msg;
                      pr-body = ''
                        ```
                        {{ env.GIT_COMMIT_MESSAGE }}
                        ```

                        @dtomvan (ping for GH mobile)
                      '';
                    };
                  }
                  {
                    run = ''
                      nix run .#write-flake
                      nix run .#write-files
                      nix fmt

                      if [[ "$(git status --porcelain | wc -l)" -gt 0 ]]; then
                        git commit -am 'chore: sync files after flake update'
                        git push origin ${branch}
                      fi
                    '';
                  }
                ];
              };
          };
        }
      ];
    };
}
