# I just refactored this out and it's ALREADY 162 lines!
{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.git;
in
{
  home.packages =
    with pkgs;
    [ watchman ]
    ++ lib.optionals cfg.jujutsuBabyMode [
      gg-jj
      lazyjj
    ];

  programs.mergiraf.enable = true;

  # damn I thought I had a lot of stuff in my git config, but jj really is
  # something else
  programs.jujutsu =
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

        # TODO: from here: do all of these REALLY need to be lists, with CRs every time?
        merge-tools = {
          mergiraf = {
            program = "mergiraf";
            merge-args = [
              "merge"
              "$base"
              "$left"
              "$right"
              "-o"
              "$output"
              "--fast"
            ];
            merge-conflict-exit-codes = [ 1 ];
            conflict-marker-style = "git";
          };
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

          up = [
            "bookmark"
            "set"
          ];

          upm = [
            "bookmark"
            "move"
            "--from"
            "heads(::@- & bookmarks())"
            "--to"
            "@-"
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
          # key = gpgPubKey; # not nessecary, should pick up from user.email
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
}
