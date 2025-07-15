# { inputs, ... }:
{
  # flake-file.inputs = {
  #   nix4vscode = {
  #     url = "github:nix-community/nix4vscode";
  #     inputs.nixpkgs.follows = "nixpkgs";
  #   };
  # };
  #
  # pkgs-overlays = [
  #   inputs.nix4vscode.overlays.forVscode
  # ];

  flake.modules.homeManager.vscode =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    let
      cfg = config.modules.vscode;
      gimmeExtensions = with pkgs.vscode-extensions; [
        # languages
        charliermarsh.ruff
        jnoortheen.nix-ide
        rust-lang.rust-analyzer
        timonwong.shellcheck
        vscodevim.vim
        golang.go
        vue.volar
        svelte.svelte-vscode
        matangover.mypy
        redhat.vscode-yaml
        redhat.vscode-xml
        tamasfe.even-better-toml
        mathiasfrohlich.kotlin
        serayuzgur.crates
        sumneko.lua
      ];
      gimmePackages = with pkgs; [
        ruff
        rustup
        shellcheck
        gopls
        mypy
        lua-language-server
      ];
    in
    {
      options.modules.vscode = {
        enable = lib.mkEnableOption "vscode config";

        extraPackages = lib.mkOption {
          description = "extra packages added to FHS env";
          type = with lib.types; nullOr (listOf package);
          default = null;
          example = lib.literalExpression ''
            with pkgs; [
              ruff
              rustup
              gopls
            ]
          '';
        };

        package = lib.mkPackageOption pkgs "vscode" {
          nullable = true;
        };

        finalPackage = lib.mkOption {
          type = lib.types.package;
          readOnly = true;
          description = "Resulting package.";
        };

        useCodium = (lib.mkEnableOption "codium instead of MS VSC") // {
          default = true;
        };

        useFHS = (lib.mkEnableOption "use `-fhs` variant for simpler extension installation") // {
          default = true;
        };

        gimmeGimmeGimme = lib.mkEnableOption "a whole bunch of language support";
      };

      config = lib.mkIf cfg.enable {

        modules.vscode = {
          finalPackage =
            let
              product = if cfg.useCodium then "vscodium" else "vscode";
              suffix = lib.optionalString cfg.useFHS "-fhs";
              hasExtraPackages = cfg.extraPackages != null;
              extraPackages = if hasExtraPackages then cfg.extraPackages else [ ];
            in
            if hasExtraPackages || cfg.gimmeGimmeGimme then
              pkgs."${product}${suffix}WithPackages" (
                _: extraPackages ++ lib.optionals cfg.gimmeGimmeGimme gimmePackages
              )
            else
              cfg.package;
        };

        programs.vscode = {
          enable = true;
          package = cfg.finalPackage;
          profiles.default = {
            enableExtensionUpdateCheck = false;
            enableUpdateCheck = false;
            extensions =
              with pkgs.vscode-extensions;
              [
                # theme
                catppuccin.catppuccin-vsc
                # niceties
                editorconfig.editorconfig
                ms-vscode-remote.remote-ssh
                ms-vscode-remote.remote-containers
                kahole.magit
              ]
              ++ lib.optionals cfg.gimmeGimmeGimme gimmeExtensions
            /*
              ++ (pkgs.nix4vscode.forOpenVsx or pkgs.nix4vscode.forVscode or (p: null)) [
                "Catppuccin.catppuccin-vsc"
                # "ms-python.python"
                # "charliermarsh.ruff"
                "EditorConfig.EditorConfig"
              ]
            */
            ;
            userSettings = {
              "[nix]"."editor.tabSize" = 2;
              "workbench.colorTheme" = "Catppuccin Mocha";
            };

            keybindings =
              # magit binds, remove when removing magit
              lib.optionals cfg.gimmeGimmeGimme [
                {
                  command = "cursorTop";
                  key = "g g";
                  when = "editorTextFocus && editorLangId == 'magit' && vim.mode =~ /^(?!SearchInProgressMode|CommandlineInProgress).*$/";
                }
                {
                  command = "magit.refresh";
                  key = "g r";
                  when = "editorTextFocus && editorLangId == 'magit' && vim.mode =~ /^(?!SearchInProgressMode|CommandlineInProgress).*$/";
                }
                {
                  command = "extension.vim_tab";
                  key = "tab";
                  when = "editorTextFocus && vim.active && !inDebugRepl && vim.mode != 'Insert' && editorLangId != 'magit'";
                }
                {
                  command = "-extension.vim_tab";
                  key = "tab";
                }
                {
                  command = "magit.discard-at-point";
                  key = "x";
                  when = "editorTextFocus && editorLangId == 'magit' && vim.mode =~ /^(?!SearchInProgressMode|CommandlineInProgress).*$/";
                }
                {
                  command = "-magit.discard-at-point";
                  key = "k";
                }
                {
                  command = "magit.reverse-at-point";
                  key = "-";
                  when = "editorTextFocus && editorLangId == 'magit' && vim.mode =~ /^(?!SearchInProgressMode|CommandlineInProgress).*$/";
                }
                {
                  command = "-magit.reverse-at-point";
                  key = "v";
                }
                {
                  command = "magit.reverting";
                  key = "shift+-";
                  when = "editorTextFocus && editorLangId == 'magit' && vim.mode =~ /^(?!SearchInProgressMode|CommandlineInProgress).*$/";
                }
                {
                  command = "-magit.reverting";
                  key = "shift+v";
                }
                {
                  command = "magit.resetting";
                  key = "shift+o";
                  when = "editorTextFocus && editorLangId == 'magit' && vim.mode =~ /^(?!SearchInProgressMode|CommandlineInProgress).*$/";
                }
                {
                  command = "-magit.resetting";
                  key = "shift+x";
                }
                {
                  command = "-magit.reset-mixed";
                  key = "x";
                }
                {
                  command = "-magit.reset-hard";
                  key = "ctrl+u x";
                }
              ];
          };
        };
      };
    };
}
