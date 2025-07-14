{
  flake.modules.homeManager.neovim =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.modules.neovim;
    in
    {
      options.modules.neovim.lsp.latex = {
        enable = lib.mkEnableOption "enable LSP and vimtex for latex typesetting";
      };
      config = lib.mkIf cfg.lsp.latex.enable {
        home.packages = with pkgs; [
          zathura
          tectonic-unwrapped
        ];
        programs.nixvim.plugins = {
          vimtex = {
            enable = true;
            settings = {
              compiler_method = "tectonic";
              view_method = "zathura";
            };
            # I'll use tectonic, which downloads only what it needs
            texlivePackage = null;
            # lazyLoad.settings.ft = ["tex"];
          };
          lsp.servers.texlab.enable = true;
        };
      };
    };
}
