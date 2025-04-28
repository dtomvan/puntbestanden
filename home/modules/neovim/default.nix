{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.modules.neovim;
in
{
  options.modules.neovim = {
    enable = lib.mkEnableOption "install and configure neovim";
    lsp = {
      enable = lib.mkEnableOption "use lspconfig and download servers";
      nixd.enable = lib.mkEnableOption "use nixd with this flake";
      rust_analyzer.enable = lib.mkEnableOption "enable rust_analyzer";
      extraLspServers = lib.mkOption {
        description = "extra LSP servers you want available in neovim";
        default = { };
        type = lib.types.attrs;
      };
    };

    enableQt = lib.mkEnableOption "QT GUI";
  };

  imports = [
    ./opts.nix
    ./keymaps.nix
    ./plugins
  ];

  config = lib.mkIf cfg.enable {
    home.packages = lib.optional cfg.enableQt pkgs.neovim-qt;

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
          initLua = false;
          plugins = true;
        };
      };

      plugins.treesitter = {
        enable = true;
        settings.highlight.enable = true;
      };
    };
  };
}
# vim:sw=2 ts=2 sts=2
