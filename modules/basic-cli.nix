{ self, lib, ... }:
{
  flake.modules.homeManager.basic-cli =
    { pkgs, ... }:
    {
      imports = with self.modules.homeManager; [
        git
        jujutsu
      ];

      home.shell.enableShellIntegration = true;

      programs.atuin.enable = true;
      programs.direnv = {
        enable = lib.mkDefault true;
        nix-direnv.enable = true; # caching
      };
      programs.zoxide.enable = lib.mkDefault true;

      programs.nix-init = {
        enable = true;
        settings = {
          maintainers = [ "dtomvan" ];
          commit = true;
          access-tokens."github.com".command = [
            (lib.getExe pkgs.gh)
            "auth"
            "token"
          ];
        };
      };

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
          '';

        shellAliases = {
          yr = "yazi result";
          n-b = "nix-build";
          nb = "nix build";
          n-s = "nix-shell";
          ns = "nix shell";

          j = "just";
          e = "nvim";
          ls = "eza";
          la = "eza -a";
          ll = "eza -lah";

          # TASK(20260414-214859): might as well remove sudo since run0 should
          # be mostly compatible and run0 is objectively cooler and should be
          # available on all nixos systems now. Also all I need is `permit
          # %wheel` and that's already [the
          # default](https://github.com/NixOS/nixpkgs/blob/7e495b747b51f95ae15e74377c5ce1fe69c1765f/nixos/modules/security/polkit.nix#L46)
          sudo = "run0";
        };
      };

      programs.zellij = {
        enable = true;

        settings = {
          pane_frames = false;
          show_startup_tips = false;
          default_shell = "bash";
          keybinds = {
            normal = {
              unbind = "Ctrl q";
            };
          };
        };

        layouts.default.layout._children = lib.singleton {
          default_tab_template._children = [
            { pane.borderless = true; }
            {
              pane = {
                size = 1;
                borderless = true;
                plugin.location = "compact-bar";
              };
            }
          ];
        };
      };

      programs.btop.enable = true;

      systemd.user.settings.Manager.DefaultEnvironment = {
        EDITOR = "nvim";
        PATH = lib.concatStringsSep ":" (
          map (p: "%u/${p}") [
            "bin"
            ".cargo/bin"
            ".local/bin"
          ]
        );
      };

      home.packages =
        let
          evalExpr =
            name: expr:
            pkgs.writeShellApplication {
              inherit name;
              excludeShellChecks = [ "SC2016" ];
              text = ''
                nix-instantiate --eval --raw --expr "${expr}"                                                                             
              '';
            };
        in
        [
          (pkgs.writeShellApplication {
            name = "jj-sync";
            text = ''
              jj git fetch
              jj evolve
              jj commit -m "$(date -Is)"
              jj tug
              jj git push
            '';
            runtimeInputs = [ pkgs.jujutsu ];
          })
          (pkgs.writeShellApplication {
            name = "jj-remote";
            text = ''
              reponame="$(basename "$(git rev-parse --show-toplevel)")"
              username="$1"
              jj git remote add "$username" "https://github.com/$username/$reponame"
            '';
          })
          (pkgs.writeShellApplication {
            name = "jj-fetch";
            text = ''
              jj git fetch --remote "$1" --branch "$2"
            '';
          })
          (pkgs.writeShellApplication {
            name = "jj-track";
            text = ''
              jj bookmark track "$2"@"$1"
            '';
          })
          (evalExpr "nix-source" ''$(printf 'with import <nixpkgs> {}; lib.concatLines [(%s.src.url or "") (%s.meta.homepage or "")]' "$@" "$@")'')
          (evalExpr "nix-maintainers" ''$(printf 'with import <nixpkgs> {}; lib.concatLines (lib.map (m: "@''${m.github}") (%s.meta.maintainers or []))' "$@")'')
          pkgs.eza
          pkgs.glab
          pkgs.forgejo-cli
          pkgs.neovim
        ];
    };

  # dim the $SHLVL to the left of the default nixos prompt when SHLVL>1
  flake.modules.nixos.profiles-base.programs.bash.promptInit = lib.mkOptionDefault ''
    PS1='\n\[\e[2m\]$(((SHLVL>1))&&echo "$SHLVL ")\[\e[0m\]'"''${PS1#'\n'}"
  '';
}
