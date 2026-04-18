{
  flake.modules.homeManager.helix =
    { self', pkgs, ... }:
    let
      inherit (self'.packages) lazyLsps;
    in
    {
      programs.helix = {
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
        extraPackages = [
          pkgs.nixd
          lazyLsps
        ];
      };
    };
}
