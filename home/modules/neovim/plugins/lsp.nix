{
  pkgs,
  config,
  lib,
  ...
}:
let
  cfg = config.modules.neovim;
  lazyPkgs = import ../../lazy-lsps.nix { inherit pkgs; };
in
{
  programs.nixvim = lib.mkIf cfg.lsp.enable {
    plugins.lspconfig.enable = true;

    extraPackages = lib.optionals cfg.lsp.lazyMoar [ lazyPkgs ];

    lsp = {
      luaConfig.post =
        lib.optionalString cfg.lsp.lazyMoar
          # please keep in sync with ../../lazy-lsps.nix
          # lua
          ''
            for _, server in ipairs {
              "bashls",
              "clangd",
              "cmake",
              "dockerls", -- dockerfile-language-server-nodejs
              "emmet_ls",
              "kotlin_language_server",
              "pyright",
              "rust_analyzer",
              "svelte",
              "taplo",
              "terraformls",
              "yamlls",
            } do
              vim.lsp.enable(server)
            end
          '';

      inlayHints.enable = true;
      servers =
        {
          lua_ls.enable = true;
        }
        // lib.optionalAttrs cfg.lsp.nixd.enable {
          nixd.enable = true;
          nixd.settings.formatting.command = [ (lib.getExe pkgs.nixfmt-rfc-style) ];
        };
    };
  };
}
