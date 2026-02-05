{ self, ... }:
{
  flake.modules.homeManager.helix =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    let
      cfg = config.modules.helix;
      lazyPkgs = self.lazy-lsps { inherit pkgs; };
    in
    {
      options.modules.helix = {
        enable = lib.mkEnableOption "install and configure hx";
        lsp.enable = lib.mkEnableOption "download servers (lazy)";
      };

      config.programs.helix = lib.mkIf cfg.enable {
        enable = true;
        settings = {
          theme = "catppuccin_mocha";
          editor = {
            cursor-shape = {
              insert = "bar";
              normal = "block";
              select = "underline";
            };

            lsp = {
              display-inlay-hints = true;
            };

            line-number = "relative";
            cursorline = true;
            rulers = [
              80
              100
            ];
            bufferline = "multiple";
            end-of-line-diagnostics = "warning";

            auto-save = {
              focus-lost = true;
              after-delay.enable = true;
            };

            indent-guides.enable = true;
          };

          keys.normal = {
            G = "goto_file_end";
          };
        };
        extraPackages = lib.mkIf cfg.lsp.enable [
          pkgs.nixd
          lazyPkgs
        ];
      };
    };
}
