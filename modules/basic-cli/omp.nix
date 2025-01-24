let
  # Gemaakt met python3
  # import json
  # json.dump({hex(x):chr(x) for x in range(0xFFFF+1) if x not in range(0xD800,0xDFFF+1)}, open("utf-8.json", "w"))
  # Dan nix repl:
  # nix eval --impure --expr 'builtins.fromJSON(builtins.readFile ./utf-8-table.json)' > utf-8-table.nix
  utf-8-table = import ../../lib/utf-8-table.nix;
  folder-icon = utf-8-table."0xe5fe";
  branch-icon = utf-8-table."0xe725";
  cherry-pick-icon = utf-8-table."0xe29b";
  commit-icon = utf-8-table."0xf417";
  merge-icon = utf-8-table."0xe727";
  no-commits-icon = utf-8-table."0xf0c3";
  rebase-icon = utf-8-table."0xe728";
  revert-icon = utf-8-table."0xf0e2";
  tag-icon = utf-8-table."0xf412";
  closer-icon = utf-8-table."0xf105";
in {
  programs.oh-my-posh = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    settings = {
      upgrade = {
        auto = false;
        notice = false;
      };
      palette = {
        os = "#ACB0BE";
        closer = "p:os";
        pink = "#F5C2E7";
        lavender = "#B4BEFE";
        blue = "#89B4FA";
      };
      blocks = [
        {
          alignment = "left";
          segments = [
            {
              foreground = "p:os";
              style = "plain";
              template = "{{.Icon}} ";
              type = "os";
            }
            {
              foreground = "p:blue";
              style = "plain";
              template = "{{ .UserName }}@{{ .HostName }} ";
              type = "session";
            }
            {
              foreground = "p:pink";
              properties = {
                folder_icon = "..${folder-icon}..";
                home_icon = "~";
                style = "agnoster_short";
              };
              style = "plain";
              template = "{{ .Path }} ";
              type = "path";
            }
            {
              foreground = "p:lavender";
              properties = {
                branch_icon = "${branch-icon} ";
                cherry_pick_icon = "${cherry-pick-icon} ";
                commit_icon = "${commit-icon} ";
                fetch_status = false;
                fetch_upstream_icon = false;
                merge_icon = "${merge-icon} ";
                no_commits_icon = "${no-commits-icon} ";
                rebase_icon = "${rebase-icon} ";
                revert_icon = "${revert-icon} ";
                tag_icon = "${tag-icon} ";
              };
              template = "{{ .HEAD }} ";
              style = "plain";
              type = "git";
            }
            {
              style = "plain";
              foreground = "p:closer";
              template = closer-icon;
              type = "text";
            }
          ];
          type = "prompt";
        }
      ];
      final_space = true;
      version = 3;
    };
  };
}
