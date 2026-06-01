# Provides a nano config, which:
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
let
  inherit (builtins) mapAttrs;
  inherit (lib)
    concatMapAttrsStringSep
    getExe
    literalExpression
    mkBefore
    mkEnableOption
    mkOption
    optionalString
    ;
  inherit (lib.types) attrsOf pathInStore;
in
{
  flake.modules.nixos.nano =
    {
      pkgs,
      config,
      ...
    }:
    let
      backupdir = "/var/lib/nano/backupdir";
      mkApp = pkg: { inherit pkg; } |> pkgs.lazy-app.override |> getExe;

      cfg = config.programs.nano;
    in
    {
      options.programs.nano.formatters = {
        enable = mkEnableOption "formatting files directly in nano";
        filetypes = mkOption {
          description = "A map from filetype to path to program used to format";
          type = attrsOf pathInStore;
          default = mapAttrs (_n: mkApp) {
            go = pkgs.gofumpt;
            json = pkgs.jq;
            nix = pkgs.nixfmt;
            python = pkgs.ruff;
            rust = pkgs.rustfmt;
            sh = pkgs.shfmt;
          };
          example = literalExpression ''
            {
              java = pkgs.astyle;
              nix = pkgs.nixfmt;
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
                mode = "0777";
                user = "root";
              };
            };
          };
        };

        # so many cool nano features which are just off by default...
        programs.nano.nanorc = mkBefore (
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
          + optionalString cfg.formatters.enable (
            concatMapAttrsStringSep "\n" (
              lang: fmt: "extendsyntax ${lang} formatter \"${fmt}\""
            ) cfg.formatters.filetypes
          )
        );

        nixpkgs.overlays = [ inputs.lazy-apps.overlays.default ];
      };
    };
}
