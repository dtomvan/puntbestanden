{
  config,
  pkgs,
  lib,
  ...
}:
with lib; {
  imports = [
    ./neovim
    ./git.nix
  ];

  home.shell.enableShellIntegration = true;

  programs.atuin = mkDefault {
    enable = true;
    flags = ["--disable-up-arrow"];
  };
  programs.direnv.enable = mkDefault true;
  programs.zoxide.enable = mkDefault true;

  programs.bash = {
    enable = true;

    initExtra = ''
      bind 'set show-all-if-ambiguous on'
      bind 'tab:menu-complete'

      c() {
          clifm "--cd-on-quit" "$@"
          dir="$(grep "^\*" "$HOME/.config/clifm/.last" 2>/dev/null | cut -d':' -f2)";
          if [ -d "$dir" ]; then
              cd -- "$dir" || return 1
          fi
      }
    '';

    shellAliases =
      {
        strider = "zellij p -- zellij:strider";
        j = "just";
        e = "nvim";
        ls = "eza";
        la = "eza -a";
        ll = "eza -lah";
        cat = "bat";
      }
      // (import ../lib/a-fuckton-of-git-aliases.nix {
        fish = false;
      });
  };

  programs.zellij = {
    enable = true;

    settings = {
      show_startup_tips = false;
      theme = "catppuccin-macchiato";
      default_shell = "bash";
      keybinds = {
        normal = {
          unbind = "Ctrl q";
        };
      };
    };
  };

  home.sessionVariables = let
    nhVersion = lib.getVersion pkgs.nh;
    flakeVar = if lib.versionAtLeast nhVersion "4.0.0" then "NH_FLAKE" else "FLAKE";
  in {
    # breaking change: see nixpkgs#401255
    ${flakeVar} = "/home/tomvd/puntbestanden/";
  };

  systemd.user.settings.Manager.DefaultEnvironment = {
    PATH = concatStringsSep ":" (map (p: "%u/${p}") [
      "bin"
      ".cargo/bin"
      ".local/bin"
    ]);
  };

  git = {
    enable = mkDefault true;
    use-gh-cli = mkDefault true;
    user = {
      name = mkDefault "Tom van Dijk";
      email = mkDefault "18gatenmaker6@gmail.com";
    };
  };

  modules.neovim = {
    enable = mkDefault true;
    lsp.enable = mkDefault true;
    lsp.latex.enable = mkDefault true;
  };
}
