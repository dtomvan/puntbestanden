{ pkgs, lib, ... }:
with lib;
{
  imports = [
    ./git.nix
    ./jujutsu.nix
    ./neovim
  ];

  home.shell.enableShellIntegration = true;

  programs.atuin = mkDefault {
    enable = true;
    enableBashIntegration = false;
  };
  programs.direnv.enable = mkDefault true;
  programs.zoxide.enable = mkDefault true;

  programs.bash = {
    enable = true;

    initExtra =
      # bash
      ''
        source "${pkgs.bash-preexec}/share/bash/bash-preexec.sh"
        bind 'set show-all-if-ambiguous on'
        bind 'tab:menu-complete'

        if [ -z "$container" ]; then
          source <(atuin init bash --disable-up-arrow)
        fi

        demo() {
          export PS1="$ "
        }

        c() {
            clifm "--cd-on-quit" "$@"
            dir="$(grep "^\*" "$HOME/.config/clifm/.last" 2>/dev/null | cut -d':' -f2)";
            if [ -d "$dir" ]; then
                cd -- "$dir" || return 1
            fi
        }
        getpath() {
          nix path-info nixpkgs#$1
        }
        yazipath() {
          yazi "$(nix path-info nixpkgs#$1)"
        }
        nix-source() {
          local expr=`printf 'with import <nixpkgs> {}; lib.concatLines [(%s.src.url or "") (%s.meta.homepage or "")]' "$@" "$@"`
          nix-instantiate --eval --raw --expr "$expr"
        }
        nix-maintainers() {
          local expr=`printf 'with import <nixpkgs> {}; lib.concatLines (lib.map (m: "@''${m.github}") (%s.meta.maintainers or []))' "$@"`
          nix-instantiate --eval --raw --expr "$expr"
        }
        jj-remote() {
          reponame="$(basename "$(git rev-parse --show-toplevel)")"
          username="$1"
          jj git remote add "$username" "https://github.com/$username/$reponame"
        }
        jj-fetch() {
          jj git fetch --remote "$1" --branch "$2"
        }
        jj-track() {
          jj bookmark track "$2"@"$1"
        }
      '';

    shellAliases = {
      # like archlinux
      upppkg = " nix flake update nixpkgs";

      yr = "yazi result";
      n-b = "nix-build";
      nb = "nix build";
      n-s = "nix-shell";
      ns = "nix shell";

      ghopen = "gh browse -R $(git remote get-url origin) -b $(git branch --show-current)";
      ghshow = "gh browse -R $(git remote get-url origin) $(git rev-parse HEAD)";
      j = "just";
      e = "nvim";
      ls = "eza";
      la = "eza -a";
      ll = "eza -lah";
      cat = "bat";

      jl = "jj l";
      jca = "jj amend";
      jst = "jj status";
      jrev = "jj revert";
      jc = "jj new";
      jd = "jj diff";
      jde = "jj describe";
      jf = "jj git fetch";
      jp = "jj git push";
      jup = "jj bookmark set";
      jb = "jj branch";
      js = "jj show";
    };
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

  home.sessionVariables =
    let
      nhVersion = lib.getVersion pkgs.nh;
      flakeVar = if lib.versionAtLeast nhVersion "4.0.0" then "NH_FLAKE" else "FLAKE";
    in
    {
      # breaking change: see nixpkgs#401255
      ${flakeVar} = "/home/tomvd/puntbestanden/";
    };

  systemd.user.settings.Manager.DefaultEnvironment = {
    PATH = concatStringsSep ":" (
      map (p: "%u/${p}") [
        "bin"
        ".cargo/bin"
        ".local/bin"
      ]
    );
  };

  modules = {
    git = {
      enable = mkDefault true;
      use-gh-cli = mkDefault true;
      user = {
        name = mkDefault "Tom van Dijk";
        email = mkDefault "18gatenmaker6@gmail.com";
      };
      jujutsuBabyMode = true;
    };

    neovim = {
      enable = mkDefault true;
      lsp.enable = mkDefault true;
      lsp.latex.enable = mkDefault true;
    };
  };
}
