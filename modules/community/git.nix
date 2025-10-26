# Sensible git defaults, I can imagine 90% of people will agree with these.
{ lib, ... }:
{
  flake.modules.homeManager.git.programs.git = {
    enable = true;

    lfs.enable = lib.mkDefault true;

    settings = {
      core = {
        excludesFile = "~/.gitignore";
        fsmonitor = true;
      };

      branch.sort = "-committerdate";
      column.ui = "auto";
      commit.verbose = true;
      format.pretty = "fuller";
      help.autocorrect = "prompt";
      init.defaultBranch = "main";
      merge.conflictstyle = "zdiff3";
      tag.sort = "version:refname";

      rerere = {
        enabled = true;
        autoupdate = true;
      };

      diff = {
        algorithm = "histogram";
        mnemonicPrefix = true;
        renames = true;
      };

      push = {
        default = "simple";
        autoSetupRemote = true;
        followTags = true;
      };
    };
  };
}
