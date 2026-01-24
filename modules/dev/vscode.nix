{
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
              ]
              ++ lib.optionals cfg.gimmeGimmeGimme gimmeExtensions;

            userSettings = {
              "[nix]"."editor.tabSize" = 2;
              "workbench.colorTheme" = "Catppuccin Mocha";
            };
          };
        };
      };
    };
}
