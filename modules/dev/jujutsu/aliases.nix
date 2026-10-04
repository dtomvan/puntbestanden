# See also modules/community/jujutsu.nix
{
  flake.modules.homeManager.jujutsu = {
    programs.jujutsu.settings = {
      aliases = {
        # prepend b to show current branch only, non-elided
        bl = [
          "log"
          "-r::@"
          "-n10"
        ];
        bll = [
          "log"
          "-r::@"
          "-n30"
        ];
        blll = [
          "log"
          "-r::@"
          "-n100"
        ];
        bllll = [
          "log"
          "-r::@"
        ];

        o = [
          "op"
          "log"
          "-T"
          "builtin_op_log_comfortable"
        ];

        wip = [
          "log"
          "-r"
          "trunk()..closest_bookmark(@-) & description(glob:\"wip:*\")"
        ];

        sync = [
          "git"
          "fetch"
          "--all-remotes"
        ];

        push = [
          "util"
          "exec"
          "--"
          "jj-pre-push"
          "--checker"
          "prek"
          "push"
        ];

        prek = [
          "run"
          "--"
          "bash"
          "-c"
          ''git show --name-only --format= "$JJ_COMMIT_ID" | xargs prek run --files''
        ];
      };
    };
  };
}
