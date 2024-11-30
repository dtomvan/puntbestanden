{
  config,
  pkgs,
  lib,
  ...
}: {
  # imports = lib.optionals config.git.enable [
  # ./scripts/git-clone.nix
  # ];
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
    delta.enable = true;
    signing = {
      signByDefault = true;
      key = "7A984C8207ADBA51";
    };
    userEmail = config.git.user.email;
    userName = config.git.user.name;
    extraConfig = {
      commit.template = "~/.gitmessage";
      format.pretty = "fuller";
      rebase.autosquash = true;
      diff.tool = "nvimdiff";
      init.defaultBranch = "main";
      advice.detachedHead = false;
	  pull.rebase = true;
    };
  };
  config.programs.gh = lib.mkIf config.git.use-gh-cli {
    enable = true;
    gitCredentialHelper.enable = true;
  };
  config.home.file.".gitmessage".source = ./git-message.txt;
}
