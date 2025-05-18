# I just refactored this out and it's ALREADY 162 lines!
# should this've been simple TOML?
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
          default-command = "l";
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
            "-Tlog1"
            "-n10"
          ];

          ll = [
            "log"
            "-Tlog1"
            "-n30"
          ];

          lll = [
            "log"
            "-Tlog1"
            "-n100"
          ];

          llll = [
            "log"
            "-Tlog1"
          ];

          L = [
            "log"
            "-Tlog2"
            "-n10"
          ];

          LL = [
            "log"
            "-Tlog2"
            "-n30"
          ];

          LLL = [
            "log"
            "-Tlog2"
            "-n100"
          ];

          LLLL = [
            "log"
            "-Tlog2"
          ];

          # prepend b to show current branch only, non-elided
          bl = [
            "log"
            "-Tlog1"
            "-r::@"
            "-n10"
          ];
          bll = [
            "log"
            "-Tlog1"
            "-r::@"
            "-n30"
          ];
          blll = [
            "log"
            "-Tlog1"
            "-r::@"
            "-n100"
          ];
          bllll = [
            "log"
            "-Tlog1"
            "-r::@"
          ];

          o = [
            "op"
            "log"
            "-T"
            "builtin_op_log_comfortable"
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

        revset-aliases = {
          "closest_bookmark(to)" = "heads(::to & bookmarks())";
        };

        template-aliases = {
          # don't even think about thinking about thinking I made this
          # https://github.com/jj-vcs/jj/discussions/5812#discussioncomment-13095720
          log1 = "smlog(original_time(committer.timestamp()), description.first_line(), bookmarks, tags)";
          "local_time(timestamp)" = ''timestamp.local().format("%Y-%m-%d %H:%M:%S")'';
          "localised_time(timestamp)" = ''timestamp.local().format("%Y-%m-%d %H:%M:%S %z")'';
          "original_time(timestamp)" = ''timestamp.format("%Y-%m-%d %H:%M:%S %z")'';
          "smlog(timestr, description, bookmarks, tags)" = ''
            if(root,
              format_root_commit(self),
              label(if(current_working_copy, "working_copy"),
                concat(
                  separate(" ",
                    format_short_change_id_with_hidden_and_divergent_info(self),
                    format_short_commit_id(commit_id),
                    timestr,
                    if(bookmarks,surround("[","]",bookmarks),""),
                    tags,
                    working_copies,
                    if(git_head, label("git_head", "git_head()")),
                    if(conflict, label("conflict", "conflict")),
                    if(empty, label("empty", "(empty)")),
                    if(author.name(), author.name(), email_placeholder),
                    if(description,
                      description,
                      label(if(empty, "empty"), description_placeholder),
                    ),
                  ) ++ "\n",
                ),
              )
            )
          '';
          log2 = "builtin_log_comfortable";
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
