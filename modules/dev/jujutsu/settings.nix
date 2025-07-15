{
  flake.modules.homeManager.jujutsu =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    {
      home.packages = [ pkgs.watchman ];

      programs.jujutsu = {
        settings = {
          inherit (config.modules.git) user;

          core = {
            watchman.register-snapshot-trigger = true;
          };

          ui = {
            default-command = "l";
            pager = ":builtin";
            diff-formatter = [
              "${lib.getExe pkgs.difftastic}"
              "--color=always"
              "$left"
              "$right"
            ];
            diff-editor = ":builtin"; # shut up
          };

          git = {
            auto-local-bookmark = true;
            private-commits = "description(glob:'wip:*') | description(glob:'private:*')";
            # see signing.behavior
            sign-on-push = true;
          };

          workspace = {
            multi-working-copy = true;
          };

          signing = {
            # not set to "own" anymore because I cannot stand the fact that even a `jj log` can ask me for my password
            behavior = "drop";
            backend = "gpg";
            # key = gpgPubKey; # not nessecary, should pick up from user.email
          };
        };
      };
    };
}
