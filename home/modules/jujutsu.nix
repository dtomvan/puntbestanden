# I just refactored this out and it's ALREADY 162 lines!
# should this've been simple TOML?
{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.modules.git;
  lazyFormatters =
    with pkgs;
    lib.map pkgs.lazy-app.override [
      { pkg = nixfmt-rfc-style; }
      { pkg = rustfmt; }
      { pkg = ruff; }
      {
        pkg = go;
        exe = "gofmt";
      }
      { pkg = shfmt; }
      { pkg = taplo; }
    ];
in
{
  home.packages =
    with pkgs;
    [
      watchman
    ]
    ++ lazyFormatters
    ++ lib.optionals cfg.jujutsuBabyMode [
      gg-jj
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
      push-bookmark-prefix = "dtomvan/push-";
    in
    lib.mkIf cfg.enable {
      enable = true;
      package = if cfg.withJujutsu then pkgs.jujutsu else null;
      # TODO: largely copy-pasta from jj wiki
      # https://jj-vcs.github.io/jj/latest
      settings = {
        inherit (cfg) user;

        core = {
          watchman.register-snapshot-trigger = true;
        };

        ui = {
          default-command = "l";
          pager = ":builtin";
          diff-formatter = [
            "${lib.getExe pkgs.difftastic}"
            "--color=always"
            "$left"
            "$right"
          ];
          diff-editor = ":builtin"; # shut up
        };

        git = {
          inherit push-bookmark-prefix;
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
            command = [ "nixfmt" ];
            patterns = [ "glob:'**/*.nix'" ];
          };
          ruff = {
            command = [
              "ruff"
              "format"
              "-"
            ];
            patterns = [ "glob:'**/*.py'" ];
          };
          gofmt = {
            command = [ "gofmt" ];
            patterns = [ "glob:'**/*.go'" ];
          };
          shfmt = {
            command = [ "shfmt" ];
            patterns = [
              "glob:'**/*.sh'"
              "glob:'**/*.bash'"
            ];
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
          taplo = {
            command = [
              "taplo"
              "format"
            ];
            patterns = [ "glob:'**/*.toml'" ];
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

          tug = [
            "bookmark"
            "move"
            "--from"
            "closest_bookmark(@-)"
            "--to"
            "@-"
          ];

          l = [
            "log"
            "-n10"
          ];

          ll = [
            "log"
            "-n30"
          ];

          lll = [
            "log"
            "-n100"
          ];

          llll = [
            "log"
            "-Tlog1"
          ];

          # prepend b to show current branch only, non-elided
          bl = [
            "log"
            "-r::@"
            "-n10"
          ];
          bll = [
            "log"
            "-r::@"
            "-n30"
          ];
          blll = [
            "log"
            "-r::@"
            "-n100"
          ];
          bllll = [
            "log"
            "-r::@"
          ];

          o = [
            "op"
            "log"
            "-T"
            "builtin_op_log_comfortable"
          ];

          branches = [
            "bookmark"
            "list"
            "-t"
            "--remote"
            "origin"
          ];

          wip = [
            "log"
            "-r"
            "trunk()..closest_bookmark(@-) & description(glob:\"wip:*\")"
          ];

          sync = [
            "git"
            "fetch"
            "--all-remotes"
          ];

          nixpkgs = [
            "git"
            "fetch"
            "--remote"
            "upstream"
          ];

          evolve = [
            "rebase"
            "--skip-emptied"
            "-d"
            "trunk()"
          ];

          push = [
            "git"
            "push"
            "-c"
            "@-"
          ];

          upload = [
            "git"
            "push"
            "-b"
            "glob:${push-bookmark-prefix}*"
          ];
        };

        signing = {
          # not set to "own" anymore because I cannot stand the fact that even a `jj log` can ask me for my password
          behavior = "drop";
          backend = "gpg";
          # key = gpgPubKey; # not nessecary, should pick up from user.email
        };

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

        template-aliases = {
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
