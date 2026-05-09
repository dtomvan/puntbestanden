{
  flake.modules.homeManager.git = {
    programs.difftastic.git.enable = true;

    programs.git = {
      enable = true;

      signing.signByDefault = false;

      settings = {
        advice.detachedHead = false;

        core = {
          untrackedCache = true;
        };

        pull.rebase = true;

        diff = {
          tool = "nvimdiff";
          colorMoved = "plain";
        };

        fetch = {
          prune = true;
          pruneTags = true;
          all = true;
        };

        rebase = {
          autoSquash = true;
          autoStash = true;
          updateRefs = true;
        };
      };
    };

    programs.gh = {
      enable = true;
      gitCredentialHelper.enable = true;
    };
  };
}
