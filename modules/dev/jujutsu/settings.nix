# See also modules/community/jujutsu.nix
{
  flake.modules.homeManager.jujutsu =
    {
      pkgs,
      lib,
      ...
    }:
    {
      programs.jujutsu = {
        settings = {
          ui = {
            pager = ":builtin";
            diff-formatter = [
              "${lib.getExe pkgs.difftastic}"
              "--color=always"
              "$left"
              "$right"
            ];
            diff-editor = ":builtin"; # shut up
          };

          revsets.git-sign-on-push = "~signed() & mine()";

          workspace = {
            multi-working-copy = true;
          };

          signing = {
            # not set to "own" anymore because I cannot stand the fact that even a `jj log` can ask me for my password
            behavior = "drop";
            backend = "gpg";
            # key = gpgPubKey; # not nessecary, should pick up from user.email
          };

          remotes.origin.auto-track-bookmarks = "glob:*";
        };
      };
    };
}
