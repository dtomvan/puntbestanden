{
  pkgs,
  config,
  lib,
  ...
}:
let
  cfg = config.modules.neovim;
  lazyPkgs = pkgs.symlinkJoin {
    name = "lazy-language-servers";
    paths =
      with pkgs;
      map lazy-app.override [
        { pkg = bash-language-server; }
        {
          pkg = clang-tools;
          exe = "clangd";
        }
        { pkg = cmake-language-server; }
        { pkg = dockerfile-language-server-nodejs; }
        { pkg = emmet-language-server; }
        { pkg = kotlin-language-server; }
        {
          pkg = pyright;
          exe = "pyright-langserver";
        }
        { pkg = svelte-language-server; }
        { pkg = taplo; }
        { pkg = terraform-ls; }
        { pkg = yaml-language-server; }
      ];
  };
in
{
  programs.nixvim = lib.mkIf cfg.lsp.enable {
    plugins.lspconfig.enable = true;

    extraPackages = lib.optionals cfg.lsp.lazyMoar [ lazyPkgs ];

    lsp = {
      luaConfig.post =
        lib.optionalString cfg.lsp.lazyMoar
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
  };
}
