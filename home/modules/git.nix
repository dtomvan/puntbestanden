{
  config,
  pkgs,
  lib,
  ...
}: {
  options = with lib; {
    git.enable = mkEnableOption "install and configure git";
    git.user.email = mkOption {
      description = "git config user.email";
      type = lib.types.str;
      default = "unknown@gmail.com";
    };
    git.user.name = mkOption {
      description = "git config user.name";
      type = lib.types.str;
      default = "Unknown";
    };
    git.use-gh-cli = mkEnableOption "install and use gh cli for authentication with github";
  };

  config.programs.git = lib.mkIf config.git.enable {
    enable = true;
    lfs.enable = true;
    difftastic.enable = true;

    signing = {
      signByDefault = true;
      key = "7A984C8207ADBA51";
    };
    userEmail = config.git.user.email;
    userName = config.git.user.name;
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
  config.programs.gh = lib.mkIf config.git.use-gh-cli {
    enable = true;
		extensions = with pkgs; [
			gh-s
			gh-dash
			gh-i
		];
    gitCredentialHelper.enable = true;
  };

	config.programs.gh-dash = lib.mkIf config.git.use-gh-cli {
		enable = true;
		settings = {
			defaults = {
				preview.width = 80;
			};
		};
	};
}
