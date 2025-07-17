{
  flake.modules.homeManager.git =
    {
      pkgs,
      ...
    }:
    {
      programs.git = {
        enable = true;

        difftastic.enable = true;
        signing.signByDefault = true;

        extraConfig = {
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
        extensions = with pkgs; [
          gh-s
          gh-dash
          gh-i
        ];
        gitCredentialHelper.enable = true;
      };

      programs.gh-dash = {
        enable = true;
        settings = {
          defaults = {
            preview.width = 80;
          };
        };
      };
    };
}
