{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  enable-bash-zsh = attrs:
    attrs
    // {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
    };
in {
  imports = [
    ./neovim
    ./zsh.nix
    ./tmux.nix
    ./git.nix
  ];

  programs.atuin = enable-bash-zsh {};
  programs.direnv = enable-bash-zsh {};
  programs.bash.enable = true;
  programs.oh-my-posh = enable-bash-zsh {
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
                folder_icon = "..\\ue5fe..";
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
                branch_icon = "\\ue725 ";
                cherry_pick_icon = "\\ue29b ";
                commit_icon = "\\uf417 ";
                fetch_status = false;
                fetch_upstream_icon = false;
                merge_icon = "\\ue727 ";
                no_commits_icon = "\\uf0c3 ";
                rebase_icon = "\\ue728 ";
                revert_icon = "\\uf0e2 ";
                tag_icon = "\\uf412 ";
              };
              template = "{{ .HEAD }} ";
              style = "plain";
              type = "git";
            }
            {
              style = "plain";
              foreground = "p:closer";
              template = "\\uf105";
              type = "text";
            }
          ];
          type = "prompt";
        }
      ];
      final_space = true;
      version = 3;
    };
    useTheme = "catppuccin_mocha";
  };

  home.packages = with pkgs; [file fd ripgrep yazi bat];
  xdg.mimeApps = {
    enable = mkDefault true;
    defaultApplications = {
      "inode/directory" = ["yazi.desktop"];
    };
  };
  home.shellAliases = {
    e =
      if config.modules.neovim.enable
      then "nvim"
      else "nano";
    ls = "${lib.getExe pkgs.eza} --icons always";
    la = "ls -a";
    ll = "ls -lah";
    cat = "${lib.getExe pkgs.bat} --color always";
    g = "git";
    gst = "git status";
    gaa = "git add -A";
    gp = "git push";
    gpf = "git push --force-with-lease";
    gpF = "git push --force";
    gc = "git commit";
    gd = "git diff";
    gdca = "git diff --cached";
  };

  home.sessionVariables = {
    # Hardcoded because nix otherwise complains and I just assume myself in this case.
    # It's not even critical, just for convenience
    FLAKE = "/home/tomvd/puntbestanden/";
  };

  # I don't know which of these two actually work, the first one doesn't seem to work...
  home.sessionPath = [
    "$HOME/.cargo/bin"
  ];

  systemd.user.settings.Manager.DefaultEnvironment = {
    PATH = "%u/bin:%u/.cargo/bin";
  };

  programs.btop = mkDefault {
    enable = true;
    settings = {
      color_theme = "${config.programs.btop.package}/share/btop/themes/gruvbox_dark.theme";
      theme_background = false;
      vim_keys = true;
      update_ms = 500;
    };
  };

  git.enable = mkDefault true;
  git.use-gh-cli = mkDefault true;
  modules.neovim = {
    enable = mkDefault true;
    use-nix-colors = mkDefault true;
    lsp.enable = mkDefault true;
    lsp.latex.enable = mkDefault true;
  };
  tmux.enable = mkDefault true;
  zsh.enable = mkDefault true;
  zsh.omz.enable = mkDefault true;
}
