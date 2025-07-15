{
  flake.modules.homeManager.jujutsu = {
    programs.jujutsu =
      let
        makeDraftDesc = d: ''
          concat(
            coalesce(description, ${d}, "\n"),
            "\nJJ: ignore-rest\n",
            diff.git(),
          )
        '';
        push-bookmark-prefix = "dtomvan/push-";
      in
      {
        settings = {
          template-aliases = {
          };

          templates = {
            duplicate_description = "concat(description, '\n(cherry picked from commit ', commit_id, ')')";
            draft_commit_description = makeDraftDesc ''""'';
            git_push_bookmark = ''"${push-bookmark-prefix}" ++ change_id.short()'';
          };
        };
      };
  };
}
