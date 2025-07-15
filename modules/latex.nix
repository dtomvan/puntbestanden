{
  flake.modules.homeManager.latex =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    let
      cfg = config.modules.latex;
    in
    {
      options.modules.latex = {
        enable = lib.mkEnableOption "TeX Live";
        package = lib.mkPackageOption pkgs "TeXLive Scheme" {
          default = "texliveSmall";
        };
        kile = lib.mkEnableOption "Kile Editor";
        neovim-lsp = {
          enable = lib.mkEnableOption "Install LSP and add to neovim config.";
          package = lib.mkPackageOption pkgs "texlab" { };
        };
      };
      config = lib.mkIf cfg.enable {
        home.packages =
          [ cfg.package ]
          ++ lib.optionals cfg.kile [ pkgs.kile ]
          ++ lib.optionals cfg.neovim-lsp.enable [ cfg.neovim-lsp.package ];

        programs.nixvim.lsp.servers = lib.mkIf cfg.neovim-lsp.enable {
          texlab.enable = true;
          texlab.package = cfg.neovim-lsp.package;
        };
      };
    };
}
