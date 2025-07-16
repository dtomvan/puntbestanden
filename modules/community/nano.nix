# This module does the following:
# - Adds `lazy-apps` to the flake.nix through github:vic/flake-file
# - Provides a nano config, which:
#   - Has sensible defaults
#   - Sets a global backupdir
#   - (optional) sets formatters for specific filetypes, possibly through lazy-apps
#
# Enable the formatters with `programs.nano.formatters.enable`
{
  lib,
  inputs,
  ...
}:
{
  flake-file.inputs.lazy-apps = lib.mkDefault {
    url = "sourcehut:~rycee/lazy-apps";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake.modules.nixos.nano =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    let
      backupdir = "/var/lib/nano/backupdir";
      mkApp =
        pkg:
        lib.pipe { inherit pkg; } [
          pkgs.lazy-app.override
          lib.getExe
        ];

      cfg = config.programs.nano;
    in
    {
      options.programs.nano.formatters = {
        enable = lib.mkEnableOption "formatting files directly in nano";
        filetypes = lib.mkOption {
          description = "A map from filetype to path to program used to format";
          type = with lib.types; attrsOf pathInStore;
          default = lib.mapAttrs (_n: mkApp) {
            go = pkgs.gofumpt;
            json = pkgs.jq;
            nix = pkgs.nixfmt-rfc-style;
            python = pkgs.ruff;
            rust = pkgs.rustfmt;
            sh = pkgs.shfmt;
          };
          example = lib.literalExpression ''
            {
              java = pkgs.astyle;
              nix = pkgs.nixfmt-rfc-style;
            }
          '';
        };
      };

      config = {
        systemd.tmpfiles.settings = {
          "10-nano-backups" = {
            ${backupdir} = {
              d = {
                group = "root";
                mode = "0666";
                user = "root";
              };
            };
          };
        };

        # so many cool nano features which are just off by default...
        programs.nano.nanorc = lib.mkBefore (
          ''
            # backup/history
            set backup
            set backupdir ${backupdir}
            set historylog
            set multibuffer
            set positionlog
            set locking

            # indentation
            set tabsize 4
            set tabstospaces

            # wrapping
            set atblanks
            set softwrap

            # UI
            set guidestripe 80
            set constantshow
            set linenumbers
            set mouse

            # smart keys
            set afterends
            set jumpyscrolling
            set zap
            set smarthome

            # search by `grep -E`
            set regexp

            # remove trailing whitespace
            set trimblanks

            # support for nano file:1:23
            set colonparsing

          ''
          + lib.optionalString cfg.formatters.enable (
            lib.concatMapAttrsStringSep "\n" (
              lang: fmt: "extendsyntax ${lang} formatter \"${fmt}\""
            ) cfg.formatters.filetypes
          )
        );

        nixpkgs.overlays = [ inputs.lazy-apps.overlays.default ];
      };
    };
}
