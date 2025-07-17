{ inputs, ... }:
{
  flake-file.inputs = {
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  flake.modules.homeManager.neovim = {
    imports = [
      inputs.nixvim.homeManagerModules.nixvim
    ];

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
  # vim:sw=2 ts=2 sts=2
}
