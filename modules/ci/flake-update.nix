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
              schedule = [ { cron = "0 5 * * 0"; } ];
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
                    name = "Get vs2nix pulls";
                    run = ''
                      vs2nix_pulls=$(gh api repos/dtomvan/vs2nix/pulls | jq -r 'map(select(.user.login == "github-actions[bot]") | "- \(.html_url)") | .[]')
                      printf "MERGE_FIRST='%s'" "$vs2nix_pulls" >> $GITHUB_ENV
                    '';
                  }
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

                        Merge first:
                        {{ env.MERGE_FIRST }}
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
