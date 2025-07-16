# See also modules/community/jujutsu.nix
{
  flake.modules.homeManager.jujutsu = {
    programs.jujutsu.settings = {
      aliases = {
        up = [
          "bookmark"
          "set"
        ];

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

        branch = [
          "bookmark"
          "list"
          "-t"
          "--remote"
          "origin"
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

        nixpkgs = [
          "git"
          "fetch"
          "--remote"
          "upstream"
        ];

        push = [
          "git"
          "push"
          "-c"
          "@-"
        ];

        # lists all bookmarks that are tracked but not authored by you and
        # aren't a bookmark for the upstream remote.
        #
        # for use with xargs to clean up spurious tracked bookmarks
        # tad nuclear probably
        not-my-bookmarks = [
          "bookmark"
          "list"
          "-t"
          "-r"
          "~mine() & ~tracked_remote_bookmarks(remote=upstream)"
          "-T"
          "if(remote, concat(name, \"@\", remote, \"\n'\"))"
        ];
      };
    };
  };
}
