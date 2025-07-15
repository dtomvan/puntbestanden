{ inputs, ... }:
{
  flake-file.inputs = {
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  flake.modules.homeManager.neovim =
    {
      lib,
      config,
      ...
    }:
    let
      cfg = config.modules.neovim;
    in
    {
      imports = [
        inputs.nixvim.homeManagerModules.nixvim
      ];

      options.modules.neovim = {
        enable = lib.mkEnableOption "install and configure neovim";
        lsp = {
          enable = lib.mkEnableOption "use lspconfig and download servers";
          nixd.enable = lib.mkEnableOption "use nixd with this flake";
          lazyMoar = lib.mkEnableOption "install a lot of LSP servers, but lazily with lazy-apps";
        };
      };

      config = lib.mkIf cfg.enable {
        programs.nixvim = {
          enable = true;
          defaultEditor = true;
          viAlias = true;
          vimAlias = true;
          vimdiffAlias = true;
          withRuby = false;

          luaLoader.enable = true;
          plugins.lz-n.enable = true;

          clipboard.register = "unnamedplus";
          clipboard.providers.wl-copy.enable = true;

          performance = {
            byteCompileLua = {
              enable = true;
              initLua = true;
              plugins = true;
            };
          };

          plugins.treesitter = {
            enable = true;
            settings.highlight.enable = true;
          };
        };
      };
    };
  # vim:sw=2 ts=2 sts=2
}
