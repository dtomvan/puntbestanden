{ self, lib, ... }:
{
  flake.modules.homeManager.basic-cli =
    { pkgs, config, ... }:
    {
      imports = builtins.attrValues {
        inherit (self.modules.homeManager)
          git
          jujutsu
          ;
      };

      home.shell.enableShellIntegration = true;

      programs.atuin = {
        enable = true;
        flags = [ "--disable-up-arrow" ];
      };

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

        initExtra = # bash
          ''
            bind 'set show-all-if-ambiguous on'
            bind 'tab:menu-complete'
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

      home.sessionVariables.EDITOR = "nvim";

      home.packages =
        let
          inherit (pkgs)
            writeShellApplication
            coreutils
            mktemp
            gum
            ;
          evalExpr =
            name: expr:
            writeShellApplication {
              inherit name;
              excludeShellChecks = [ "SC2016" ];
              text = ''
                nix-instantiate --eval --raw --expr "${expr}"                                                                             
              '';
            };
        in
        [
          (writeShellApplication {
            name = "jj-sync";
            text = ''
              jj git fetch
              jj evolve
              jj commit -m "$(date -Is)"
              jj tug
              jj git push
            '';
            runtimeInputs = lib.singleton config.programs.jujutsu.package;
          })
          (writeShellApplication {
            name = "jj-remote";
            runtimeInputs = lib.singleton config.programs.jujutsu.package;
            text = ''
              reponame="$(basename "$(git rev-parse --show-toplevel)")"
              username="$1"
              jj git remote add "$username" "https://github.com/$username/$reponame"
            '';
          })
          (writeShellApplication {
            name = "jj-fetch";
            runtimeInputs = lib.singleton config.programs.jujutsu.package;
            text = ''
              jj git fetch --remote "$1" --branch "$2"
            '';
          })
          (writeShellApplication {
            name = "jj-track";
            runtimeInputs = lib.singleton config.programs.jujutsu.package;
            text = ''
              jj bookmark track "$2"@"$1"
            '';
          })
          (evalExpr "nix-source" ''$(printf 'with import <nixpkgs> {}; lib.concatLines [(%s.src.url or "") (%s.meta.homepage or "")]' "$@" "$@")'')
          (evalExpr "nix-maintainers" ''$(printf 'with import <nixpkgs> {}; lib.concatLines (lib.map (m: "@''${m.github}") (%s.meta.maintainers or []))' "$@")'')
          (writeShellApplication {
            name = "big-command";
            runtimeInputs = [
              coreutils
              mktemp
              gum
            ];
            text = ''
              # assumes shell is in path
              shell="$(basename "''${SHELL:?}")"
              tmp="$(mktemp /tmp/XXXXXXX.sh)"
              test -w "$tmp"
              chmod +x "$tmp"
              { echo "#!/usr/bin/env $shell"; echo; } >> "$tmp"
              "$EDITOR" "$tmp"
              gum confirm --default=no "Run \`$tmp\`?"$'\n\n'"$(cat "$tmp")"
              "$tmp" || true
              code="$?"
              echo "Program was $tmp" >&2
              echo "exit $code" >&2
              exit "$code"
            '';
          })
        ]
        ++ builtins.attrValues {
          inherit (pkgs)
            eza
            glab
            forgejo-cli
            neovim
            ;
        };

      programs.git-credential-keepassxc.enable = true;
    };

  # dim the $SHLVL to the left of the default nixos prompt when SHLVL>1
  flake.modules.nixos.profiles-base.programs.bash.promptInit = lib.mkOptionDefault ''
    PS1='\n\[\e[2m\]$(((SHLVL>1))&&echo "$SHLVL ")\[\e[0m\]'"''${PS1#'\n'}"
  '';
}
