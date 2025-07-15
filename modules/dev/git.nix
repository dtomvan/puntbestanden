{
  flake.modules.homeManager.git =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      cfg = config.modules.git;
    in
    {
      options.modules.git = with lib; {
        enable = mkEnableOption "install and configure git";
        use-gh-cli = mkEnableOption "install and use gh cli for authentication with github";
      };

      config.programs.git = lib.mkIf cfg.enable {
        enable = true;
        lfs.enable = true;
        difftastic.enable = true;

        signing.signByDefault = true;

        extraConfig = {
          advice.detachedHead = false;
          commit = {
            verbose = true;
          };
          core = {
            excludesFile = "~/.gitignore";
            fsmonitor = true;
            untrackedCache = true;
          };
          rerere = {
            enabled = true;
            autoupdate = true;
          };
          format.pretty = "fuller";
          init.defaultBranch = "main";
          pull.rebase = true;
          column.ui = "auto";
          branch.sort = "-committerdate";
          tag.sort = "version:refname";
          diff = {
            tool = "nvimdiff";
            algorithm = "histogram";
            colorMoved = "plain";
            mnemonicPrefix = true;
            renames = true;
          };
          push = {
            default = "simple";
            autoSetupRemote = true;
            followTags = true;
          };
          fetch = {
            prune = true;
            pruneTags = true;
            all = true;
          };
          merge.conflictstyle = "zdiff3";
          help.autocorrect = "prompt";
          rebase = {
            autoSquash = true;
            autoStash = true;
            updateRefs = true;
          };
        };
      };

      config.programs.gh = lib.mkIf cfg.use-gh-cli {
        enable = true;
        extensions = with pkgs; [
          gh-s
          gh-dash
          gh-i
        ];
        gitCredentialHelper.enable = true;
      };

      config.programs.gh-dash = lib.mkIf cfg.use-gh-cli {
        enable = true;
        settings = {
          defaults = {
            preview.width = 80;
          };
        };
      };
    };
}
