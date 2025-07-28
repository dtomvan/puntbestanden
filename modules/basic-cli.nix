{ config, ... }:
{
  flake.modules.homeManager.basic-cli =
    { pkgs, lib, ... }:
    with lib;
    {
      imports = with config.flake.modules.homeManager; [
        git
        jujutsu
      ];

      home.shell.enableShellIntegration = true;

      programs.atuin = mkDefault {
        enable = true;
        enableBashIntegration = false;
      };
      programs.direnv = {
        enable = mkDefault true;
        nix-direnv.enable = true; # caching
      };
      programs.zoxide.enable = mkDefault true;

      programs.bash = {
        enable = true;

        initExtra =
          # bash
          ''
            export EDITOR=nvim
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

            direnvify() {
              local top="$(git rev-parse --show-toplevel)"
              echo '/.envrc' >> "$top/.git/info/exclude"
              echo 'use flake' >> "$top/.envrc"
              direnv allow
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

      systemd.user.settings.Manager.DefaultEnvironment = {
        PATH = concatStringsSep ":" (
          map (p: "%u/${p}") [
            "bin"
            ".cargo/bin"
            ".local/bin"
          ]
        );
      };
    };
}
