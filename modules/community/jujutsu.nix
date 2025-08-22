# Sensible defaults for jujutsu and aliases.
{ lib, ... }:
{
  flake.modules.homeManager.jujutsu =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [ watchman ];

      programs.jujutsu.settings = {
        fsmonitor.watchman.register-snapshot-trigger = lib.mkDefault true;
        ui.default-command = lib.mkDefault "l";

        git.private-commits = lib.mkDefault "description(glob:'wip:*') | description(glob:'private:*')";

        aliases = lib.mapAttrs (_n: lib.mkDefault) {
          set = [
            "config"
            "set"
            "--repo"
          ];

          watch = [
            "config"
            "set"
            "--repo"
            "fsmonitor.backend"
            "watchman"
          ];

          unwatch = [
            "config"
            "set"
            "--repo"
            "fsmonitor.backend"
            "none"
          ];

          # moves the bookmark that you are basing the current working copy off
          # of to @-
          # Example:
          #  - jj new main
          #  - echo a >> a.txt
          #  - jj commit -m "changes in a"
          #  - jj tug
          #  -> main now points to the commit called "changes in a"
          tug = [
            "bookmark"
            "move"
            "--from"
            "closest_bookmark(@-)"
            "--to"
            "@-"
          ];

          # I use `jj l` as the default log command, so I don't see as much
          # stuff at the same time. As you need more logs you can append another
          # l
          l = [
            "log"
            "-n10"
          ];

          ll = [
            "log"
            "-n30"
          ];

          lll = [
            "log"
            "-n100"
          ];

          # rebases the current branch to master
          evolve = [
            "rebase"
            "--skip-emptied"
            "-d"
            "trunk()"
          ];
        };
      };
    };
}
