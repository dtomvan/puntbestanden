{
  flake.modules.homeManager.jujutsu = {
    programs.jujutsu.settings = {
      revsets = {
        # less shit, hopefully faster under nixpkgs
        log = "@ | ancestors(trunk()..(visible_heads() & mine()), 2) | trunk()";
      };

      revset-aliases = {
        "closest_bookmark(to)" = "heads(::to & bookmarks())";
        "unpushed()" = "remote_bookmarks()..";
        "this_unpushed()" = "::@ & remote_bookmarks()..";
        "unmerged()" = "tracked_remote_bookmarks(remote=upstream).. & mine()";
        "this_unmerged()" = "::@ & tracked_remote_bookmarks(remote=upstream).. & mine()";
        "my_branches()" = "remote_bookmarks(remote=origin) & ~remote_bookmarks(remote=upstream) & mine()";
        "my_unmerged_branches()" = "my_branches() & unmerged()";
        "my_unnamed()" = "tracked_remote_bookmarks(dtomvan/push-, remote=origin)";
        "unused_bookmarks()" = "~master@upstream:: & ~master@origin:: & ~unmerged()";
      };
    };
  };
}
