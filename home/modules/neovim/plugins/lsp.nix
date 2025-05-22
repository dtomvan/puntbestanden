{
  pkgs,
  config,
  lib,
  ...
}:
let
  cfg = config.modules.neovim;
in
{
  programs.nixvim.lsp = lib.mkIf cfg.lsp.enable {
    inlayHints.enable = true;
    servers =
      {
        lua_ls.enable = true;
      }
      // cfg.lsp.extraLspServers
      // lib.optionalAttrs cfg.lsp.rust_analyzer.enable {
        rust_analyzer = {
          enable = true;
        };
      }
      // lib.optionalAttrs cfg.lsp.nixd.enable {
        nixd.enable = true;
        nixd.settings.formatting.command = [ (lib.getExe pkgs.nixfmt-rfc-style) ];
      };
  };
}
