{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.git;
  gpgPubKey = "7A984C8207ADBA51";
in
{
  options.git = with lib; {
    enable = mkEnableOption "install and configure git";
    user.email = mkOption {
      description = "git config user.email";
      type = lib.types.str;
      default = "unknown@gmail.com";
    };
    user.name = mkOption {
      description = "git config user.name";
      type = lib.types.str;
      default = "Unknown";
    };
    use-gh-cli = mkEnableOption "install and use gh cli for authentication with github";

    withJujutsu = (mkEnableOption "jujutsu") // {
      default = true;
    };

    jujutsuBabyMode = mkEnableOption "jujutsu {t,g}ui";
  };

  config.home.packages =
    with pkgs;
    [ watchman ]
    ++ lib.optionals cfg.jujutsuBabyMode [
      gg-jj
      lazyjj
    ];

  config.programs.jujutsu =
    let
      makeDraftDesc = d: ''
        concat(
          coalesce(description, ${d}, "\n"),
          "\nJJ: ignore-rest\n",
          diff.git(),
        )
      '';
    in
    lib.mkIf cfg.enable {
      enable = true;
      package = if cfg.withJujutsu then pkgs.jujutsu else null;
      # TODO: largely copy-pasta from jj wiki
      # https://jj-vcs.github.io/jj/latest
      settings = {
        inherit (cfg) user;
        ui = {
          default-command = "log";
          pager = ":builtin";
          diff.tool = [
            "${lib.getExe pkgs.difftastic}"
            "--color=always"
            "$left"
            "$right"
          ];
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
        fix.tools = {
          nixfmt = {
            command = [ "${lib.getExe pkgs.nixfmt-rfc-style}" ];
            patterns = [ "glob:'**/*.nix'" ];
          };
          rustfmt = {
            enabled = false;
            command = [
              "rustfmt"
              "--emit"
              "stdout"
            ];
            patterns = [ "glob:'**/*.rs'" ];
          };
        };
        aliases = {
          set = [
            "config"
            "set"
            "--repo"
          ];
          watch = [
            "config"
            "set"
            "--repo"
            "core.fsmonitor"
            "watchman"
          ];
          unwatch = [
            "config"
            "set"
            "--repo"
            "core.fsmonitor"
            "none"
          ];
          l = [
            "log"
            "-r"
            "(main..@):: | (main..@)-"
          ];
        };
        signing = {
          # not set to "own" anymore because I cannot stand the fact that even a `jj log` can ask me for my password
          behavior = "drop";
          backend = "gpg";
          key = gpgPubKey; # not nessecary, should pick up from user.email
        };
        revsets = {
          mine = "author('${cfg.user.email}')";
        };
        templates.draft_commit_description = makeDraftDesc ''""'';
        # "--scope" = [
        #   {
        #     "--when".repositories = [ "~/puntbestanden" ];
        #     templates.draft_commit_description = makeDraftDesc "commit.committer().timestamp().format('%c')";
        #   }
        # ];
      };
    };

  config.programs.git = lib.mkIf cfg.enable {
    enable = true;
    lfs.enable = true;
    difftastic.enable = true;

    signing = {
      signByDefault = true;
      key = gpgPubKey;
    };
    userEmail = cfg.user.email;
    userName = cfg.user.name;
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
}
